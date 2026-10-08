import 'package:appmetrica_plugin/appmetrica_plugin.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_sink.dart';

/// Тонкая обёртка над статическим API AppMetrica; в тестах подменяется фейком.
abstract interface class AppMetricaClient {
  /// Отправляет событие.
  Future<void> reportEvent(String name, Map<String, Object>? parameters);

  /// Устанавливает идентификатор профиля.
  Future<void> setUserProfileId(String? userId);

  /// Устанавливает атрибут профиля.
  Future<void> setAttribute(String key, Object value);
}

/// Настоящий клиент AppMetrica.
final class PluginAppMetricaClient implements AppMetricaClient {
  /// Создаёт клиент.
  const PluginAppMetricaClient();

  /// Активирует AppMetrica с [apiKey].
  ///
  /// Отправку сбоев отключаем: ошибки остаются в Sentry.
  static Future<void> activate({required String apiKey, required bool logs}) => AppMetrica.activate(
    AppMetricaConfig(
      apiKey,
      crashReporting: false,
      nativeCrashReporting: false,
      flutterCrashReporting: false,
      anrMonitoring: false,
      locationTracking: false,
      logs: logs,
    ),
  );

  @override
  Future<void> reportEvent(String name, Map<String, Object>? parameters) =>
      AppMetrica.reportEventWithMap(name, parameters);

  @override
  Future<void> setUserProfileId(String? userId) => AppMetrica.setUserProfileID(userId);

  @override
  Future<void> setAttribute(String key, Object value) {
    final attribute = switch (value) {
      final bool flag => AppMetricaBooleanAttribute.withValue(key, flag),
      final num number => AppMetricaNumberAttribute.withValue(key, number.toDouble()),
      _ => AppMetricaStringAttribute.withValue(key, '$value'),
    };

    return AppMetrica.reportUserProfile(AppMetricaUserProfile([attribute]));
  }
}

/// Отправляет события в AppMetrica. Единственное место, где используется `appmetrica_plugin`.
final class AppMetricaAnalyticsSink implements TailsAnalyticsSink {
  /// Создаёт приёмник.
  const AppMetricaAnalyticsSink({AppMetricaClient client = const PluginAppMetricaClient()})
    : _client = client;

  final AppMetricaClient _client;

  @override
  String get name => 'appmetrica';

  @override
  Future<void> logEvent(TailsAnalyticsEvent event) =>
      _client.reportEvent(event.name, event.parameters.isEmpty ? null : event.parameters);

  @override
  Future<void> setUserId(String? userId) => _client.setUserProfileId(userId);

  @override
  Future<void> setUserProperty(TailsAnalyticsUserProperty property, Object value) =>
      _client.setAttribute(property.key, value);
}
