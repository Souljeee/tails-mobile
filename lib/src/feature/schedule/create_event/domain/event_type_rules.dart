import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';

/// Правила, связывающие тип события в интерфейсе с типом в API и с повторением.
abstract final class EventTypeRules {
  /// «Приём лекарств» в интерфейсе — один пункт; в API он `dailyPills` или `weeklyPills`.
  static bool isMedication(ScheduleEventTypeEnum type) =>
      type == ScheduleEventTypeEnum.dailyPills || type == ScheduleEventTypeEnum.weeklyPills;

  /// Тип в том виде, как он отображается в выборе: оба вида лекарств — один пункт.
  static ScheduleEventTypeEnum pickerType(ScheduleEventTypeEnum type) =>
      isMedication(type) ? ScheduleEventTypeEnum.dailyPills : type;

  /// Тип, который уходит на сервер.
  ///
  /// Лекарства с повторением «каждый день» — `dailyPills`, любое другое расписание (в том числе
  /// без повторения) — `weeklyPills`. Остальные типы отправляются как есть.
  static ScheduleEventTypeEnum apiType(ScheduleEventTypeEnum selected, RecurrenceModel? rule) {
    if (!isMedication(selected)) {
      return selected;
    }

    final isEveryDay = rule != null && rule.period == RecurrencePeriod.day && rule.interval == 1;

    return isEveryDay ? ScheduleEventTypeEnum.dailyPills : ScheduleEventTypeEnum.weeklyPills;
  }

  /// Период, который подставляется, если повторение ещё не настраивали; `null` — не подставляем.
  static RecurrencePeriod? defaultPeriod(ScheduleEventTypeEnum type) {
    if (type == ScheduleEventTypeEnum.yearlyVaccination) {
      return RecurrencePeriod.year;
    }
    if (isMedication(type)) {
      return RecurrencePeriod.day;
    }

    return null;
  }
}
