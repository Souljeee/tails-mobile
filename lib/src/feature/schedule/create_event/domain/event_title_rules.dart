import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

/// Что делать с названием события при выборе типа.
enum EventTitleAction {
  /// Оставить как есть.
  keep,

  /// Подставить название типа.
  fill,

  /// Очистить подставленное название (тип «Другое»).
  clear,

  /// Название пользователя: оставить и предложить заменить на название типа.
  suggest,
}

/// Правила взаимодействия названия события и выбранного типа.
abstract final class EventTitleRules {
  /// [current] — текст в поле, [autofilled] — подставлен ли он нами, [previousType] — тип до
  /// выбора, [typeName] — название нового типа.
  static EventTitleAction onTypeSelected({
    required String current,
    required bool autofilled,
    required ScheduleEventTypeEnum? previousType,
    required ScheduleEventTypeEnum newType,
    required String typeName,
  }) {
    final title = current.trim();

    if (newType == ScheduleEventTypeEnum.custom) {
      return autofilled && title.isNotEmpty ? EventTitleAction.clear : EventTitleAction.keep;
    }
    if (title.isEmpty || autofilled) {
      return EventTitleAction.fill;
    }
    if (title == typeName || previousType == null || previousType == newType) {
      return EventTitleAction.keep;
    }

    return EventTitleAction.suggest;
  }
}
