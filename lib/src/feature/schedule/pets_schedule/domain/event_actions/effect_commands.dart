import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/event_actions_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/schedule/schedule_bloc.dart';

/// Какие команды получает список расписания в ответ на эффект [EventActionsBloc].
///
/// Вынесено из экрана, чтобы правила (что откатывать, когда перезагружать окно) проверялись
/// тестами. Экран только отправляет эти команды в `ScheduleBloc`.
List<ScheduleEvent> scheduleCommandsFor(EventActionEffect effect) {
  final ref = effect.occurrence.ref;

  return switch (effect) {
    EventActionEffect$CancelApplied(:final scope) => [
      ScheduleEvent.occurrenceCancelledChanged(
        ref: ref,
        cancelled: true,
        dropFollowing: scope == OccurrenceScope.future,
      ),
    ],
    // Отмена «и все следующие» убрала вхождения серии: вернуть их можно только перезагрузкой.
    EventActionEffect$CancelUndone(:final scope) ||
    EventActionEffect$CancelFailed(:final scope) => [
      ScheduleEvent.occurrenceCancelledChanged(ref: ref, cancelled: false),
      if (scope == OccurrenceScope.future) const ScheduleEvent.refreshRequested(),
    ],
    EventActionEffect$CancelCommitted(:final scope) => [
      if (scope == OccurrenceScope.future) const ScheduleEvent.refreshRequested(),
    ],
    EventActionEffect$RestoreApplied() => [
      ScheduleEvent.occurrenceCancelledChanged(ref: ref, cancelled: false),
    ],
    EventActionEffect$RestoreFailed() => [
      ScheduleEvent.occurrenceCancelledChanged(ref: ref, cancelled: true),
    ],
    EventActionEffect$RestoreCommitted() => const [],
  };
}
