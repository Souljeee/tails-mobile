import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

/// Пишет события аналитики в журнал приложения (уровень trace).
///
/// Помогает увидеть, что и когда отправляется, не заходя в консоль сервисов.
final class LogAnalyticsSink implements TailsAnalyticsSink {
  /// Создаёт приёмник.
  const LogAnalyticsSink();

  @override
  String get name => 'log';

  @override
  Future<void> logEvent(TailsAnalyticsEvent event) async {
    TailsLogger.trace(
      'Событие аналитики',
      source: 'TailsAnalytics',
      data: {'event': event.name, ...event.parameters},
    );
  }

  @override
  Future<void> setUserId(String? userId) async {
    TailsLogger.trace(
      userId == null ? 'Аналитика: пользователь сброшен' : 'Аналитика: пользователь привязан',
      source: 'TailsAnalytics',
    );
  }

  @override
  Future<void> setUserProperty(TailsAnalyticsUserProperty property, Object value) async {
    TailsLogger.trace(
      'Свойство пользователя аналитики',
      source: 'TailsAnalytics',
      data: {'property': property.key, 'value': value},
    );
  }
}
