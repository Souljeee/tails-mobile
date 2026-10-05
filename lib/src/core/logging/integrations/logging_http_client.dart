import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tails_mobile/src/core/logging/tails_log_context.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sanitizer.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

/// HTTP-клиент, который пишет в журнал каждый запрос, ответ и сбой.
///
/// Оборачивает другой [http.Client] и ничего не меняет в обмене: запрос уходит как есть,
/// ответ возвращается с теми же статусом, заголовками и телом. Для записи тело ответа
/// читается целиком и отдаётся вызывающему коду заново.
///
/// ```text
/// 12:03:40.474 I NET  api  → #41 GET /pets/ headers={...}
/// 12:03:40.612 I NET  api  ← #41 200 GET /pets/ 138ms 3.4KB headers={...} body=[...]
/// 12:05:21.320 E NET  api  ✕ #57 GET /pets/124/ 10014ms
///     ↳ ClientException(Connection timed out)
/// ```
///
/// Что пишется:
///
/// * заголовки запроса и ответа: значения `Authorization`, `Cookie` и других чувствительных
///   заголовков заменяются на `[REDACTED]`;
/// * query-параметры с чувствительными ключами скрываются;
/// * тела JSON и текста разбираются, очищаются санитайзером и обрезаются до
///   `bodyMaxLength` символов. Очистка идёт до обрезки, поэтому обрезанный фрагмент
///   не раскрывает секрет;
/// * для multipart — только имена полей, имена файлов и их размер, без содержимого;
/// * для бинарных данных — только тип и размер.
///
/// Уровни: 2xx и 3xx — `info`, 4xx — `warning`, 5xx и сбои соединения — `error`. Записи
/// об ошибках идут с `report: false`: ошибку отправляет в сервис отчётов тот слой, который
/// её владеет (блок или глобальный обработчик), иначе она ушла бы дважды.
final class LoggingHttpClient extends http.BaseClient {
  /// Создаёт клиент-обёртку над `inner`.
  ///
  /// `label` — имя клиента в журнале (`api`, `public`, `auth-refresh`): записи разных
  /// клиентов легко различить. `bodyMaxLength` ограничивает размер тела в записи.
  LoggingHttpClient(
    this._inner, {
    this.label = 'http',
    this.bodyMaxLength = 1000,
    TailsLogSanitizer sanitizer = const TailsLogSanitizer(),
  }) : _sanitizer = sanitizer;

  static int _lastRequestId = 0;

  final http.Client _inner;

  /// Имя клиента в журнале.
  final String label;

  /// Сколько символов тела попадает в запись.
  final int bodyMaxLength;

  final TailsLogSanitizer _sanitizer;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!TailsLogger.isEnabled(TailsLogLevel.error, TailsLogCategory.network)) {
      return _inner.send(request);
    }

    final id = ++_lastRequestId;
    final path = request.url.path;
    final stopwatch = Stopwatch()..start();

    _safely(() => _logRequest(id, request, path));

    final http.StreamedResponse streamed;
    final List<int> bytes;
    try {
      streamed = await _inner.send(request);
      bytes = await streamed.stream.toBytes();
    } on Object catch (error, stackTrace) {
      stopwatch.stop();
      _safely(
        () => _logFailure(id, request, path, stopwatch.elapsedMilliseconds, error, stackTrace),
      );

      rethrow;
    }

    stopwatch.stop();
    _safely(() => _logResponse(id, request, path, stopwatch.elapsedMilliseconds, streamed, bytes));

    return http.StreamedResponse(
      http.ByteStream.fromBytes(bytes),
      streamed.statusCode,
      contentLength: bytes.length,
      request: streamed.request,
      headers: streamed.headers,
      isRedirect: streamed.isRedirect,
      persistentConnection: streamed.persistentConnection,
      reasonPhrase: streamed.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();

  void _logRequest(int id, http.BaseRequest request, String path) {
    if (!TailsLogger.isEnabled(TailsLogLevel.info, TailsLogCategory.network)) return;

    TailsLogger.info(
      '→ #$id ${request.method} $path',
      category: TailsLogCategory.network,
      source: label,
      data: {
        if (TailsLogContext.screen case final screen?) 'screen': screen,
        if (request.url.hasQuery) 'query': _query(request.url),
        'headers': _sanitizer.sanitizeHeaders(request.headers),
        ..._requestBody(request),
      },
    );
  }

  void _logResponse(
    int id,
    http.BaseRequest request,
    String path,
    int durationMs,
    http.StreamedResponse response,
    List<int> bytes,
  ) {
    final status = response.statusCode;
    final level = switch (status) {
      >= 500 => TailsLogLevel.error,
      >= 400 => TailsLogLevel.warning,
      _ => TailsLogLevel.info,
    };
    if (!TailsLogger.isEnabled(level, TailsLogCategory.network)) return;

    final body = _body(bytes, response.headers['content-type']);
    final data = <String, Object?>{
      'headers': _sanitizer.sanitizeHeaders(response.headers),
      if (body != null) 'body': body,
    };
    final message = '← #$id $status ${request.method} $path ${durationMs}ms ${_size(bytes.length)}';

    switch (level) {
      case TailsLogLevel.error:
        TailsLogger.error(
          message,
          category: TailsLogCategory.network,
          source: label,
          data: data,
          report: false,
        );
      case TailsLogLevel.warning:
        TailsLogger.warning(message, category: TailsLogCategory.network, source: label, data: data);
      default:
        TailsLogger.info(message, category: TailsLogCategory.network, source: label, data: data);
    }
  }

  void _logFailure(
    int id,
    http.BaseRequest request,
    String path,
    int durationMs,
    Object error,
    StackTrace stackTrace,
  ) {
    TailsLogger.error(
      '✕ #$id ${request.method} $path ${durationMs}ms',
      category: TailsLogCategory.network,
      source: label,
      error: error,
      stackTrace: stackTrace,
      report: false,
    );
  }

  Map<String, Object?> _query(Uri url) => _sanitizer.sanitizeData({
    for (final MapEntry(:key, :value) in url.queryParametersAll.entries)
      key: value.length == 1 ? value.single : value,
  });

  Map<String, Object?> _requestBody(http.BaseRequest request) {
    switch (request) {
      case http.Request(:final bodyBytes) when bodyBytes.isNotEmpty:
        return {'body': _body(bodyBytes, request.headers['content-type'])};
      case http.MultipartRequest(:final fields, :final files):
        return {
          if (fields.isNotEmpty) 'fields': _sanitizer.sanitizeData({...fields}),
          if (files.isNotEmpty)
            'files': [
              for (final file in files)
                {
                  'field': file.field,
                  if (file.filename != null) 'filename': file.filename,
                  'size': _size(file.length),
                  if (file.contentType.mimeType.isNotEmpty) 'type': file.contentType.mimeType,
                },
            ],
        };
      default:
        return const {};
    }
  }

  /// Описывает тело для журнала: очищенную структуру JSON или текст, а для бинарных
  /// данных — только тип и размер. Слишком длинное тело обрезается.
  Object? _body(List<int> bytes, String? contentType) {
    if (bytes.isEmpty) return null;

    final type = (contentType ?? '').toLowerCase();
    final isJson = type.contains('json');
    final isText =
        isJson ||
        type.startsWith('text/') ||
        type.contains('xml') ||
        type.contains('x-www-form-urlencoded');

    if (type.isNotEmpty && !isText) return '[$contentType, ${_size(bytes.length)}]';

    final String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      return '[бинарные данные, ${_size(bytes.length)}]';
    }

    Object? value = text;
    if (isJson || type.isEmpty) {
      try {
        value = jsonDecode(text);
      } on FormatException {
        value = text;
      }
    }

    // Сначала очищаем, потом обрезаем: обрезанный по символам JSON уже не разобрать по ключам.
    final sanitized = _sanitizer.sanitizeValue(value);
    final encoded = sanitized is String ? sanitized : jsonEncode(sanitized);

    if (encoded.length <= bodyMaxLength) return sanitized;

    return '${encoded.substring(0, bodyMaxLength)}…[обрезано ${encoded.length - bodyMaxLength} симв.]';
  }

  static String _size(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Сбой журналирования не должен ломать запрос.
  static void _safely(void Function() action) {
    try {
      action();
    } on Object {
      // Журнал вспомогательный: запрос важнее записи о нём.
    }
  }
}
