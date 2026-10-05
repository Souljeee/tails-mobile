import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intercepted_client/intercepted_client.dart';
import 'package:tails_mobile/src/core/logging/integrations/logging_http_client.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

import '../../../helpers/recording_log_sink.dart';

void main() {
  late RecordingLogSink sink;

  setUp(() {
    sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
  });

  tearDown(TailsLogger.reset);

  LoggingHttpClient clientFor(
    Future<http.Response> Function(http.Request request) handler, {
    int bodyMaxLength = 1000,
  }) => LoggingHttpClient(MockClient(handler), label: 'api', bodyMaxLength: bodyMaxLength);

  http.Response json(Object body, {int status = 200}) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );

  group('LoggingHttpClient', () {
    test('пишет запрос и ответ и не меняет ответ для вызывающего кода', () async {
      final client = clientFor((_) async => json({'name': 'Бакс'}));

      final response = await client.get(Uri.parse('https://api.test/pets/3/'));

      expect(response.statusCode, 200);
      expect(jsonDecode(response.body), {'name': 'Бакс'});
      expect(response.headers['content-type'], contains('json'));

      final events = sink.events;
      expect(events, hasLength(2));
      expect(events[0].message, '→ #${_id(events[0])} GET /pets/3/');
      expect(events[1].message, matches(RegExp(r'^← #\d+ 200 GET /pets/3/ \d+ms \d+B$')));
      expect(events.every((event) => event.category == TailsLogCategory.network), isTrue);
      expect(events.every((event) => event.source == 'api'), isTrue);
      expect(events.every((event) => event.level == TailsLogLevel.info), isTrue);
      expect(events[1].data['body'], {'name': 'Бакс'});
    });

    test('номера запросов растут, номер запроса и ответа совпадает', () async {
      final client = clientFor((_) async => json({}));

      await client.get(Uri.parse('https://api.test/a/'));
      await client.get(Uri.parse('https://api.test/b/'));

      final ids = sink.events.map(_id).toList();
      expect(ids[0], ids[1]);
      expect(ids[2], ids[3]);
      expect(int.parse(ids[2]), int.parse(ids[0]) + 1);
    });

    test('скрывает чувствительные заголовки', () async {
      final client = clientFor(
        (_) async => http.Response('{}', 200, headers: {'set-cookie': 'sid=1'}),
      );

      await client.get(
        Uri.parse('https://api.test/pets/'),
        headers: {'Authorization': 'Bearer abc.def', 'Accept': 'application/json'},
      );

      final request = sink.events[0].data['headers']! as Map<Object?, Object?>;
      expect(request['Authorization'], '[REDACTED]');
      expect(request['Accept'], 'application/json');
      final response = sink.events[1].data['headers']! as Map<Object?, Object?>;
      expect(response['set-cookie'], '[REDACTED]');
    });

    test('очищает query, тела запроса и ответа', () async {
      final client = clientFor(
        (_) async => json({'access': 'a-1', 'refresh': 'r-1', 'phoneNumber': '+79001112233'}),
      );

      await client.post(
        Uri.parse('https://api.test/auth/?code=1234&page=2'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'password': 'hunter2', 'name': 'Анна'}),
      );

      expect(sink.events[0].data['query'], {'code': '[REDACTED]', 'page': '2'});
      expect(sink.events[0].data['body'], {'password': '[REDACTED]', 'name': 'Анна'});
      expect(sink.events[1].data['body'], {
        'access': '[REDACTED]',
        'refresh': '[REDACTED]',
        'phoneNumber': '+7***2233',
      });
      final all = sink.events.map((event) => '${event.data}').join();
      expect(all, isNot(contains('hunter2')));
      expect(all, isNot(contains('a-1')));
      expect(all, isNot(contains('79001112233')));
    });

    test('выбирает уровень по статусу и не отправляет сетевые записи в сервис отчётов', () async {
      final client = clientFor((request) async {
        return switch (request.url.path) {
          '/missing/' => json({'detail': 'нет'}, status: 404),
          '/broken/' => json({'detail': 'сбой'}, status: 500),
          _ => json({}),
        };
      });

      await client.get(Uri.parse('https://api.test/ok/'));
      await client.get(Uri.parse('https://api.test/missing/'));
      await client.get(Uri.parse('https://api.test/broken/'));

      final responses = sink.events.where((event) => event.message.startsWith('←')).toList();
      expect(responses.map((event) => event.level), [
        TailsLogLevel.info,
        TailsLogLevel.warning,
        TailsLogLevel.error,
      ]);
      expect(
        sink.events.where((event) => event.level == TailsLogLevel.error).every((e) => !e.report),
        isTrue,
      );
      expect(responses[2].data['body'], {'detail': 'сбой'});
    });

    test('сбой соединения пишет error и пробрасывает ту же ошибку со стеком', () async {
      final failure = http.ClientException('Connection timed out');
      final client = LoggingHttpClient(MockClient((_) async => throw failure), label: 'api');

      Object? caught;
      try {
        await client.get(Uri.parse('https://api.test/pets/124/'));
      } on Object catch (error) {
        caught = error;
      }

      expect(caught, same(failure));
      final event = sink.events.last;
      expect(event.level, TailsLogLevel.error);
      expect(event.message, matches(RegExp(r'^✕ #\d+ GET /pets/124/ \d+ms$')));
      expect(event.error, same(failure));
      expect(event.stackTrace, isNotNull);
      expect(event.report, isFalse);
    });

    test('обрезает длинное тело после очистки', () async {
      final client = clientFor((_) async => json({'text': 'x' * 500}), bodyMaxLength: 50);

      await client.get(Uri.parse('https://api.test/long/'));

      final body = sink.events[1].data['body']! as String;
      expect(body, startsWith('{"text":"xxxx'));
      expect(body, contains('…[обрезано'));
    });

    test('секрет не раскрывается обрезанным фрагментом', () async {
      final client = clientFor(
        (_) async => json({'token': 'secret-value-123', 'pad': 'y' * 200}),
        bodyMaxLength: 30,
      );

      await client.get(Uri.parse('https://api.test/t/'));

      expect('${sink.events[1].data}', isNot(contains('secret-value')));
    });

    test('бинарный ответ описывается только типом и размером', () async {
      final client = clientFor(
        (_) async => http.Response.bytes(
          List<int>.filled(2048, 7),
          200,
          headers: {'content-type': 'image/png'},
        ),
      );

      final response = await client.get(Uri.parse('https://api.test/photo.png'));

      expect(response.bodyBytes, hasLength(2048));
      expect(sink.events[1].data['body'], '[image/png, 2.0KB]');
      expect(sink.events[1].message, endsWith('2.0KB'));
    });

    test('multipart: только имена полей и файлов, без содержимого', () async {
      final client = clientFor((_) async => json({}));
      final request = http.MultipartRequest('POST', Uri.parse('https://api.test/feedback/'))
        ..fields['message'] = 'телефон +79001112233'
        ..fields['password'] = 'hunter2'
        ..files.add(
          http.MultipartFile.fromBytes(
            'screenshot',
            List<int>.filled(3000, 1),
            filename: 'screen.png',
          ),
        );

      await client.send(request);

      final data = sink.events[0].data;
      expect(data['fields'], {'message': 'телефон +7***2233', 'password': '[REDACTED]'});
      expect(data['files'], [
        {
          'field': 'screenshot',
          'filename': 'screen.png',
          'size': '2.9KB',
          'type': 'application/octet-stream',
        },
      ]);
    });

    test('ничего не пишет и не буферизует, если журнал не нужен', () async {
      TailsLogger.reset();
      final client = clientFor((_) async => json({'ok': true}));

      final response = await client.get(Uri.parse('https://api.test/pets/'));

      expect(jsonDecode(response.body), {'ok': true});
      expect(sink.events, isEmpty);
    });

    test('сбой журналирования не ломает запрос', () async {
      TailsLogger.configure(sinks: [_ThrowingSink()]);
      final client = clientFor((_) async => json({'ok': true}));

      final response = await client.get(Uri.parse('https://api.test/pets/'));

      expect(response.statusCode, 200);
    });

    test('поверх InterceptedClient видит запрос, отклонённый перехватчиком', () async {
      final client = LoggingHttpClient(
        InterceptedClient(
          inner: MockClient((_) async => json({})),
          interceptors: [_RejectingInterceptor()],
        ),
        label: 'api',
      );

      await expectLater(client.get(Uri.parse('https://api.test/pets/')), throwsStateError);

      expect(sink.events.map((event) => event.message.substring(0, 1)), ['→', '✕']);
      expect(sink.events.last.error, isA<StateError>());
    });

    test('close закрывает внутренний клиент', () {
      final inner = _CloseSpyClient();

      LoggingHttpClient(inner).close();

      expect(inner.closed, isTrue);
    });
  });
}

String _id(TailsLogEvent event) => RegExp(r'#(\d+)').firstMatch(event.message)!.group(1)!;

final class _ThrowingSink implements TailsLogSink {
  @override
  bool isEnabled(TailsLogLevel level, TailsLogCategory category) => true;

  @override
  void write(TailsLogEvent event) => throw StateError('sink failed');
}

final class _CloseSpyClient extends http.BaseClient {
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => throw UnimplementedError();

  @override
  void close() => closed = true;
}

final class _RejectingInterceptor extends SequentialHttpInterceptor {
  @override
  Future<void> interceptRequest(http.BaseRequest request, RequestHandler handler) async =>
      handler.rejectRequest(StateError('токен недействителен'));
}
