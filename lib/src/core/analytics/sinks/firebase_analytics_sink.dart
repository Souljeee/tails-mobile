import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_sink.dart';

/// Тонкая обёртка над Firebase Analytics; в тестах подменяется фейком.
abstract interface class FirebaseAnalyticsClient {
  /// Включает или выключает сбор.
  Future<void> setCollectionEnabled({required bool enabled});

  /// Отправляет событие.
  Future<void> logEvent(String name, Map<String, Object>? parameters);

  /// Отправляет просмотр экрана.
  Future<void> logScreenView(String screenName);

  /// Отправляет стандартное событие регистрации.
  Future<void> logSignUp(String method);

  /// Устанавливает идентификатор пользователя.
  Future<void> setUserId(String? userId);

  /// Устанавливает свойство пользователя.
  Future<void> setUserProperty(String name, String? value);
}

/// Настоящий клиент Firebase Analytics.
final class PluginFirebaseAnalyticsClient implements FirebaseAnalyticsClient {
  /// Создаёт клиент.
  const PluginFirebaseAnalyticsClient();

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  @override
  Future<void> setCollectionEnabled({required bool enabled}) =>
      _analytics.setAnalyticsCollectionEnabled(enabled);

  @override
  Future<void> logEvent(String name, Map<String, Object>? parameters) =>
      _analytics.logEvent(name: name, parameters: parameters);

  @override
  Future<void> logScreenView(String screenName) => _analytics.logScreenView(screenName: screenName);

  @override
  Future<void> logSignUp(String method) => _analytics.logSignUp(signUpMethod: method);

  @override
  Future<void> setUserId(String? userId) => _analytics.setUserId(id: userId);

  @override
  Future<void> setUserProperty(String name, String? value) =>
      _analytics.setUserProperty(name: name, value: value);
}

/// Отправляет события в Firebase Analytics. Единственное место, где используется
/// `firebase_analytics`.
///
/// Firebase принимает только строки и числа, поэтому bool превращается в 0/1.
final class FirebaseAnalyticsSink implements TailsAnalyticsSink {
  /// Создаёт приёмник.
  const FirebaseAnalyticsSink({
    FirebaseAnalyticsClient client = const PluginFirebaseAnalyticsClient(),
  }) : _client = client;

  final FirebaseAnalyticsClient _client;

  static const _maxPropertyLength = 36;

  /// Включает сбор (по умолчанию он выключен в нативной конфигурации).
  Future<void> enableCollection() => _client.setCollectionEnabled(enabled: true);

  @override
  String get name => 'firebase';

  @override
  Future<void> logEvent(TailsAnalyticsEvent event) async {
    if (event.name == TailsAnalyticsEvents.screenViewName) {
      final screen = event.parameters['screen_name'];
      if (screen is String) await _client.logScreenView(screen);

      return;
    }

    final parameters = {
      for (final entry in event.parameters.entries)
        entry.key: switch (entry.value) {
          final bool flag => flag ? 1 : 0,
          final Object value => value,
        },
    };
    await _client.logEvent(event.name, parameters.isEmpty ? null : parameters);

    if (event.name == TailsAnalyticsEvents.signupCompletedName) {
      await _client.logSignUp('sms');
    }
  }

  @override
  Future<void> setUserId(String? userId) => _client.setUserId(userId);

  @override
  Future<void> setUserProperty(TailsAnalyticsUserProperty property, Object value) {
    final text = switch (value) {
      final bool flag => flag ? 'true' : 'false',
      _ => '$value',
    };
    final clipped = text.length <= _maxPropertyLength
        ? text
        : text.substring(0, _maxPropertyLength);

    return _client.setUserProperty(property.key, clipped);
  }
}
