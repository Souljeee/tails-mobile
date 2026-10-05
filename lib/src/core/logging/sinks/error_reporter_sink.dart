import 'dart:async';
import 'dart:developer' as developer;

import 'package:clock/clock.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sink.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/error_reporter.dart';

/// Отправляет ошибки из журнала во внешний сервис через [ErrorReporter].
///
/// Принимает записи не ниже [TailsLogConfig.reportMinLevel], которым не запрещена отправка
/// (`report: false`). Одна и та же ошибка отправляется один раз, даже если её записали
/// несколько слоёв (см. [ErrorReportDeduplicator]). Конкретный сервис (Sentry, Crashlytics)
/// скрыт за [ErrorReporter], поэтому замена сервиса этот класс не затрагивает.
final class ErrorReporterSink implements TailsLogSink {
  /// Создаёт sink.
  ErrorReporterSink({
    required ErrorReporter reporter,
    required TailsLogConfig config,
    ErrorReportDeduplicator? deduplicator,
  }) : _reporter = reporter,
       _config = config,
       _deduplicator = deduplicator ?? ErrorReportDeduplicator();

  final ErrorReporter _reporter;
  final TailsLogConfig _config;
  final ErrorReportDeduplicator _deduplicator;

  @override
  bool isEnabled(TailsLogLevel level, TailsLogCategory category) =>
      level.isAtLeast(_config.reportMinLevel) && _reporter.isInitialized;

  @override
  void write(TailsLogEvent event) {
    if (!event.report) return;
    if (_deduplicator.isDuplicate(error: event.error, stackTrace: event.stackTrace)) return;

    final stackTrace = event.stackTrace ?? StackTrace.current;
    unawaited(_capture(event.error ?? ReportedMessageException(event.message), stackTrace));
  }

  Future<void> _capture(Object throwable, StackTrace stackTrace) async {
    try {
      await _reporter.captureException(throwable: throwable, stackTrace: stackTrace);
    } on Object catch (error, captureStackTrace) {
      developer.log(
        'Не удалось отправить ошибку в сервис отчётов',
        name: 'ErrorReporterSink',
        error: error,
        stackTrace: captureStackTrace,
      );
    }
  }
}

/// Не даёт отправить одну и ту же ошибку дважды.
///
/// Ошибка проходит через несколько слоёв: `BlocObserver.onError`, затем (если Bloc
/// пробрасывает исключение дальше) обработчик зоны, а `rest_client` ещё и оборачивает
/// исключения, сохраняя исходный стек. Поэтому ошибка считается повтором, если за последние
/// [window] уже была запись с тем же объектом ошибки или с тем же текстом стека.
///
/// Записи без ошибки и без стека (только сообщение) не проверяются.
final class ErrorReportDeduplicator {
  /// Создаёт фильтр, который помнит не больше [capacity] ошибок за последние [window].
  ErrorReportDeduplicator({this.window = const Duration(seconds: 5), this.capacity = 50});

  /// Как долго ошибка считается недавней.
  final Duration window;

  /// Сколько ошибок помнить.
  final int capacity;

  final List<_SeenError> _seen = [];

  /// Возвращает `true`, если такая ошибка уже была недавно; иначе запоминает её.
  bool isDuplicate({Object? error, StackTrace? stackTrace}) {
    final stackText = stackTrace?.toString().trim();
    final hasStack = stackText != null && stackText.isNotEmpty;
    final comparableError = error != null && _isComparableByIdentity(error) ? error : null;

    if (comparableError == null && !hasStack) return false;

    final now = clock.now();
    _seen.removeWhere((seen) => now.difference(seen.time) > window);

    final duplicate = _seen.any(
      (seen) =>
          (comparableError != null && identical(seen.error, comparableError)) ||
          (hasStack && seen.stackText == stackText),
    );
    if (duplicate) return true;

    _seen.add(
      _SeenError(time: now, error: comparableError, stackText: hasStack ? stackText : null),
    );
    if (_seen.length > capacity) _seen.removeAt(0);

    return false;
  }

  /// Строки и числа могут быть одним и тем же объектом у разных ошибок (константы),
  /// поэтому сравнивать их по тождеству нельзя.
  static bool _isComparableByIdentity(Object error) =>
      error is! String && error is! num && error is! bool;
}

final class _SeenError {
  const _SeenError({required this.time, required this.error, required this.stackText});

  final DateTime time;
  final Object? error;
  final String? stackText;
}
