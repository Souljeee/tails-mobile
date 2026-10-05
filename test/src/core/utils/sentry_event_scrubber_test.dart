// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sanitizer.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/sentry_event_scrubber.dart';

void main() {
  const r = TailsLogSanitizer.redacted;
  const scrubber = SentryEventScrubber();
  final hint = Hint();

  test('очищает текст сообщения и исключений', () {
    final event = SentryEvent(
      message: const SentryMessage('Ошибка для +79001112233'),
      exceptions: [SentryException(type: 'StateError', value: 'Bearer abc.def password=hunter2')],
    );

    final result = scrubber.scrubEvent(event, hint);

    expect(result.message!.formatted, 'Ошибка для +7***2233');
    expect(result.exceptions!.single.value, 'Bearer $r password=$r');
    expect(result.exceptions!.single.type, 'StateError');
  });

  test('удаляет из запроса тело, cookie, заголовки и строку запроса', () {
    final event = SentryEvent(
      request: SentryRequest(
        url: 'https://api.example.com/users/79001112233/',
        method: 'POST',
        queryString: 'token=abc',
        cookies: 'sid=1',
        data: {'password': 'x'},
        headers: {'Authorization': 'Bearer abc'},
      ),
    );

    final request = scrubber.scrubEvent(event, hint).request!;

    expect(request.url, 'https://api.example.com/users/+7***2233/');
    expect(request.method, 'POST');
    expect(request.queryString, isNull);
    expect(request.cookies, isNull);
    expect(request.data, isNull);
    expect(request.headers, isEmpty);
  });

  test('очищает breadcrumbs внутри события', () {
    final event = SentryEvent(
      breadcrumbs: [
        Breadcrumb(message: 'звонок 89001112233', data: {'access_token': 'abc'}),
      ],
    );

    final crumb = scrubber.scrubEvent(event, hint).breadcrumbs!.single;

    expect(crumb.message, 'звонок +8***2233');
    expect(crumb.data, {'access_token': r});
  });

  test('beforeBreadcrumb очищает данные и сохраняет категорию, уровень и время', () {
    final time = DateTime.utc(2026, 10, 5);
    final crumb = Breadcrumb(
      message: 'ok',
      category: 'http',
      level: SentryLevel.warning,
      data: {'url': 'https://x/?token=abc', 'password': 'p'},
      timestamp: time,
    );

    final result = scrubber.scrubBreadcrumb(crumb, hint)!;

    expect(result.category, 'http');
    expect(result.level, SentryLevel.warning);
    expect(result.timestamp, time);
    expect(result.data!['password'], r);
    expect(result.data!['url'], isNot(contains('abc')));
  });

  test('beforeBreadcrumb пропускает null', () {
    expect(scrubber.scrubBreadcrumb(null, hint), isNull);
  });

  test('событие без запроса и сообщения не ломается', () {
    final result = scrubber.scrubEvent(SentryEvent(), hint);

    expect(result.request, isNull);
    expect(result.message, isNull);
  });
}
