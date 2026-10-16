import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_status.dart';

/// Действия, которые шит деталей может предложить над вхождением.
enum EventAction {
  /// Снять отметку о выполнении.
  unmarkDone,

  /// Открыть форму редактирования.
  edit,

  /// Перейти к отмене.
  cancel,

  /// Вернуть отменённое событие в расписание.
  restore,
}

/// Какие действия доступны в каждом состоянии вхождения.
///
/// - запланировано: изменить, отменить;
/// - выполнено: снять отметку, изменить (отменить нельзя: сервер отвечает 409, сначала снимают
///   отметку);
/// - отменено: у одиночного события «Вернуть в расписание»; у вхождения серии действий нет,
///   вернуть его можно только кнопкой в снекбаре сразу после отмены.
abstract final class EventActionRules {
  static List<EventAction> available(ScheduleEventModel occurrence) => switch (occurrence.status) {
    ScheduleEventStatus.scheduled => const [EventAction.edit, EventAction.cancel],
    ScheduleEventStatus.done => const [EventAction.unmarkDone, EventAction.edit],
    ScheduleEventStatus.cancelled =>
      occurrence.recurrence == null ? const [EventAction.restore] : const [],
  };

  static bool isAvailable(ScheduleEventModel occurrence, EventAction action) =>
      available(occurrence).contains(action);
}
