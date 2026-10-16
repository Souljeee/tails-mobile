part of 'event_actions_bloc.dart';

sealed class EventActionsEvent extends Equatable {
  const EventActionsEvent();

  /// Отмена вхождения: состояние меняется сразу, запрос уходит через [EventActionsBloc.undoDelay].
  const factory EventActionsEvent.cancelRequested({
    required ScheduleEventModel occurrence,
    required OccurrenceScope scope,
  }) = EventActionsEvent$CancelRequested;

  /// «Вернуть» в снекбаре: запрос не отправлялся, откат без обращения к серверу.
  const factory EventActionsEvent.undoRequested() = EventActionsEvent$UndoRequested;

  /// Отправить отложенную отмену немедленно (снекбар закрыт, уход с экрана, сворачивание).
  const factory EventActionsEvent.flushRequested() = EventActionsEvent$FlushRequested;

  /// Вернуть отменённое вхождение в расписание (запрос уходит сразу).
  const factory EventActionsEvent.restoreRequested({required ScheduleEventModel occurrence}) =
      EventActionsEvent$RestoreRequested;

  T map<T>({
    required T Function(EventActionsEvent$CancelRequested event) cancelRequested,
    required T Function(EventActionsEvent$UndoRequested event) undoRequested,
    required T Function(EventActionsEvent$FlushRequested event) flushRequested,
    required T Function(EventActionsEvent$RestoreRequested event) restoreRequested,
  }) => switch (this) {
    final EventActionsEvent$CancelRequested event => cancelRequested(event),
    final EventActionsEvent$UndoRequested event => undoRequested(event),
    final EventActionsEvent$FlushRequested event => flushRequested(event),
    final EventActionsEvent$RestoreRequested event => restoreRequested(event),
  };
}

final class EventActionsEvent$CancelRequested extends EventActionsEvent {
  final ScheduleEventModel occurrence;
  final OccurrenceScope scope;

  const EventActionsEvent$CancelRequested({required this.occurrence, required this.scope});

  @override
  List<Object?> get props => [occurrence, scope];
}

final class EventActionsEvent$UndoRequested extends EventActionsEvent {
  const EventActionsEvent$UndoRequested();

  @override
  List<Object?> get props => [];
}

final class EventActionsEvent$FlushRequested extends EventActionsEvent {
  const EventActionsEvent$FlushRequested();

  @override
  List<Object?> get props => [];
}

final class EventActionsEvent$RestoreRequested extends EventActionsEvent {
  final ScheduleEventModel occurrence;

  const EventActionsEvent$RestoreRequested({required this.occurrence});

  @override
  List<Object?> get props => [occurrence];
}
