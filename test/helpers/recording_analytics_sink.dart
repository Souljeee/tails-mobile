import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_sink.dart';

/// Приёмник аналитики для тестов: запоминает всё, что получил.
final class RecordingAnalyticsSink implements TailsAnalyticsSink {
  /// Принятые события.
  final List<TailsAnalyticsEvent> events = [];

  /// История привязок пользователя.
  final List<String?> userIds = [];

  /// Установленные свойства.
  final Map<TailsAnalyticsUserProperty, Object> properties = {};

  /// Имена принятых событий.
  List<String> get names => events.map((event) => event.name).toList();

  @override
  String get name => 'recording';

  @override
  Future<void> logEvent(TailsAnalyticsEvent event) async => events.add(event);

  @override
  Future<void> setUserId(String? userId) async => userIds.add(userId);

  @override
  Future<void> setUserProperty(TailsAnalyticsUserProperty property, Object value) async =>
      properties[property] = value;
}
