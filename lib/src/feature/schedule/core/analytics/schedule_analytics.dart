import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';

/// Переводит доменные модели расписания в параметры событий аналитики.
///
/// Здесь только закрытые значения (тип события, период, способ окончания): без названий,
/// описаний и дат.
abstract final class ScheduleAnalytics {
  /// Тип события в `snake_case`: `vetVisit` → `vet_visit`.
  static String eventType(ScheduleEventTypeEnum type) => TailsAnalyticsEvents.snake(type.name);

  /// Период повторения: `day`, `week`, `month`, `year`.
  static String period(RecurrencePeriod period) => period.name;

  /// Способ окончания: `never`, `until`, `count`.
  static String end(RecurrenceEnd end) => switch (end) {
    RecurrenceEnd$Never() => 'never',
    RecurrenceEnd$Until() => 'until',
    RecurrenceEnd$AfterCount() => 'count',
  };

  /// Событие `event_created` по модели создания.
  static TailsAnalyticsEvent eventCreated(CreateEventModel model) {
    final rule = model.isRecurring ? model.recurrence : null;

    return TailsAnalyticsEvents.eventCreated(
      eventType: eventType(model.type),
      hasTime: model.time != null,
      hasDescription: (model.description ?? '').trim().isNotEmpty,
      isRecurring: rule != null,
      recurrencePeriod: rule == null ? null : period(rule.period),
      recurrenceInterval: rule?.interval,
      recurrenceEnd: rule == null ? null : end(rule.end),
      timesPerDay: rule == null || rule.period != RecurrencePeriod.day
          ? null
          : (rule.times.length < 2 ? 1 : rule.times.length),
    );
  }

  /// Событие `recurrence_saved` по правилу.
  static TailsAnalyticsEvent recurrenceSaved(RecurrenceModel rule) =>
      TailsAnalyticsEvents.recurrenceSaved(
        period: period(rule.period),
        interval: rule.interval,
        end: end(rule.end),
      );
}
