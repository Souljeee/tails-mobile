import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/analytics/sinks/appmetrica_analytics_sink.dart';
import 'package:tails_mobile/src/core/analytics/sinks/firebase_analytics_sink.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_sanitizer.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_sink.dart';

import '../../../helpers/recording_analytics_sink.dart';

final class _ThrowingSink implements TailsAnalyticsSink {
  @override
  String get name => 'throwing';

  @override
  Future<void> logEvent(TailsAnalyticsEvent event) => throw StateError('boom');

  @override
  Future<void> setUserId(String? userId) => throw StateError('boom');

  @override
  Future<void> setUserProperty(TailsAnalyticsUserProperty property, Object value) =>
      throw StateError('boom');
}

final class _FakeAppMetrica implements AppMetricaClient {
  final events = <(String, Map<String, Object>?)>[];
  final attributes = <String, Object>{};
  String? userId;

  @override
  Future<void> reportEvent(String name, Map<String, Object>? parameters) async =>
      events.add((name, parameters));

  @override
  Future<void> setAttribute(String key, Object value) async => attributes[key] = value;

  @override
  Future<void> setUserProfileId(String? userId) async => this.userId = userId;
}

final class _FakeFirebase implements FirebaseAnalyticsClient {
  final events = <(String, Map<String, Object>?)>[];
  final screens = <String>[];
  final signUps = <String>[];
  final properties = <String, String?>{};

  @override
  Future<void> logEvent(String name, Map<String, Object>? parameters) async =>
      events.add((name, parameters));

  @override
  Future<void> logScreenView(String screenName) async => screens.add(screenName);

  @override
  Future<void> logSignUp(String method) async => signUps.add(method);

  @override
  Future<void> setCollectionEnabled({required bool enabled}) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperty(String name, String? value) async => properties[name] = value;
}

void main() {
  tearDown(TailsAnalytics.reset);

  group('TailsAnalyticsSanitizer', () {
    const sanitizer = TailsAnalyticsSanitizer();

    test('отклоняет недопустимое имя события', () {
      expect(sanitizer.sanitize(const TailsAnalyticsEvent('Bad Name')), isNull);
      expect(sanitizer.sanitize(const TailsAnalyticsEvent('1event')), isNull);
    });

    test('удаляет запрещённые ключи и недопустимые типы', () {
      final event = sanitizer.sanitize(
        const TailsAnalyticsEvent(
          'x',
          parameters: {
            'phone': '+79991234567',
            'pet_name': 'Барсик',
            'auth_token': 'abc',
            'screen_name': 'home',
            'count': 2,
            'flag': true,
            'bad': <int>[1],
          },
        ),
      )!;

      expect(event.parameters.keys, unorderedEquals(['screen_name', 'count', 'flag']));
    });

    test('ограничивает число параметров и длину строк', () {
      final event = sanitizer.sanitize(
        TailsAnalyticsEvent('x', parameters: {for (var i = 0; i < 20; i++) 'k$i': 'a' * 300}),
      )!;

      expect(event.parameters.length, TailsAnalyticsSanitizer.maxParameters);
      expect(event.parameters.values.every((v) => (v as String).length <= 100), isTrue);
    });

    test('очищает телефон в значении', () {
      final event = sanitizer.sanitize(
        const TailsAnalyticsEvent('x', parameters: {'note': 'звоните +7 999 123-45-67'}),
      )!;

      expect(event.parameters['note'], isNot(contains('999 123')));
    });
  });

  group('TailsAnalytics', () {
    test('вызов до configure безопасен', () {
      TailsAnalytics.log(TailsAnalyticsEvents.logout);
      TailsAnalytics.setUser('1');
      TailsAnalytics.clearUser();
    });

    test('рассылает события, пользователя и свойства всем приёмникам', () async {
      final a = RecordingAnalyticsSink();
      final b = RecordingAnalyticsSink();
      TailsAnalytics.configure(sinks: [a, b]);
      TailsAnalytics.log(TailsAnalyticsEvents.logout);
      TailsAnalytics.setUser('u1');
      TailsAnalytics.clearUser();
      TailsAnalytics.setUserProperty(TailsAnalyticsUserProperty.petsCount, 2);
      await Future<void>.delayed(Duration.zero);

      for (final sink in [a, b]) {
        expect(sink.names, ['logout']);
        expect(sink.userIds, ['u1', null]);
        expect(sink.properties[TailsAnalyticsUserProperty.petsCount], 2);
      }
    });

    test('сбой одного приёмника не мешает другим', () async {
      final ok = RecordingAnalyticsSink();
      TailsAnalytics.configure(sinks: [_ThrowingSink(), ok]);
      TailsAnalytics.log(TailsAnalyticsEvents.logout);
      TailsAnalytics.setUser('u1');
      await Future<void>.delayed(Duration.zero);

      expect(ok.names, ['logout']);
      expect(ok.userIds, ['u1']);
    });

    test('недопустимое событие не доходит до приёмников', () async {
      final sink = RecordingAnalyticsSink();
      TailsAnalytics.configure(sinks: [sink]);
      TailsAnalytics.log(const TailsAnalyticsEvent('Bad'));
      await Future<void>.delayed(Duration.zero);

      expect(sink.events, isEmpty);
    });
  });

  group('AppMetricaAnalyticsSink', () {
    test('передаёт событие, пользователя и атрибуты', () async {
      final client = _FakeAppMetrica();
      final sink = AppMetricaAnalyticsSink(client: client);

      await sink.logEvent(TailsAnalyticsEvents.loginSucceeded(isNewUser: true));
      await sink.logEvent(TailsAnalyticsEvents.logout);
      await sink.setUserId('u1');
      await sink.setUserProperty(TailsAnalyticsUserProperty.hasRecurringEvents, true);

      expect(client.events[0].$1, 'login_succeeded');
      expect(client.events[0].$2, {'is_new_user': true});
      expect(client.events[1].$1, 'logout');
      expect(client.events[1].$2, isNull);
      expect(client.userId, 'u1');
      expect(client.attributes['has_recurring_events'], true);
    });
  });

  group('FirebaseAnalyticsSink', () {
    test('bool превращается в 0/1', () async {
      final client = _FakeFirebase();
      await FirebaseAnalyticsSink(
        client: client,
      ).logEvent(TailsAnalyticsEvents.loginSucceeded(isNewUser: false));

      expect(client.events.single.$1, 'login_succeeded');
      expect(client.events.single.$2, {'is_new_user': 0});
    });

    test('screen_view уходит как logScreenView', () async {
      final client = _FakeFirebase();
      await FirebaseAnalyticsSink(client: client).logEvent(TailsAnalyticsEvents.screenView('home'));

      expect(client.screens, ['home']);
      expect(client.events, isEmpty);
    });

    test('signup_completed дополнительно шлёт sign_up', () async {
      final client = _FakeFirebase();
      await FirebaseAnalyticsSink(client: client).logEvent(TailsAnalyticsEvents.signupCompleted);

      expect(client.events.single.$1, 'signup_completed');
      expect(client.signUps, ['sms']);
    });

    test('свойства пользователя — строки до 36 символов', () async {
      final client = _FakeFirebase();
      final sink = FirebaseAnalyticsSink(client: client);
      await sink.setUserProperty(TailsAnalyticsUserProperty.hasRecurringEvents, true);
      await sink.setUserProperty(TailsAnalyticsUserProperty.appTheme, 'x' * 50);

      expect(client.properties['has_recurring_events'], 'true');
      expect(client.properties['app_theme']!.length, 36);
    });
  });

  group('TailsAnalyticsEvents', () {
    test('корзины', () {
      expect([0, 1, 2, 3, 4, 10].map(TailsAnalyticsEvents.countBucket), [
        '0',
        '1',
        '2-3',
        '2-3',
        '4+',
        '4+',
      ]);
      expect([0, 1, 3, 4, 7, 8].map(TailsAnalyticsEvents.ageBucket), [
        '<1',
        '1-3',
        '1-3',
        '4-7',
        '4-7',
        '8+',
      ]);
    });

    test('snake_case для имён enum', () {
      expect(TailsAnalyticsEvents.snake('vetVisit'), 'vet_visit');
    });

    test('все события каталога проходят санитайзер', () {
      const sanitizer = TailsAnalyticsSanitizer();
      final events = <TailsAnalyticsEvent>[
        TailsAnalyticsEvents.petCreated(
          petType: 'dog',
          sex: 'male',
          isMixed: false,
          hasPhoto: true,
          isCastrated: false,
          ageBucket: '1-3',
          petsCount: 1,
          isFirstPet: true,
        ),
        TailsAnalyticsEvents.eventCreated(
          eventType: 'vaccination',
          hasTime: true,
          hasDescription: false,
          isRecurring: true,
          isFirstEvent: false,
          recurrencePeriod: 'day',
          recurrenceInterval: 1,
          recurrenceEnd: 'never',
          timesPerDay: 2,
        ),
        TailsAnalyticsEvents.screenView('home'),
        TailsAnalyticsEvents.sheetView('pet_picker'),
        TailsAnalyticsEvents.errorStateShown(screen: 'home', reason: AnalyticsReason.network),
        TailsAnalyticsEvents.appSettingChanged(setting: 'theme', value: 'dark'),
      ];

      for (final event in events) {
        final clean = sanitizer.sanitize(event)!;
        expect(clean.parameters.length, event.parameters.length, reason: event.name);
      }
    });
  });
}
