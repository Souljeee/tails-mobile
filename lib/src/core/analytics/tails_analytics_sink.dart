import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';

/// Получатель событий аналитики (AppMetrica, Firebase, журнал).
///
/// Получает уже очищенные данные. Сбой получателя не должен влиять на остальных:
/// диспетчер перехватывает исключения.
abstract interface class TailsAnalyticsSink {
  /// Короткое имя для диагностики.
  String get name;

  /// Отправляет событие.
  Future<void> logEvent(TailsAnalyticsEvent event);

  /// Привязывает события к пользователю; `null` снимает привязку.
  Future<void> setUserId(String? userId);

  /// Устанавливает свойство пользователя. [value] — String, num или bool.
  Future<void> setUserProperty(TailsAnalyticsUserProperty property, Object value);
}
