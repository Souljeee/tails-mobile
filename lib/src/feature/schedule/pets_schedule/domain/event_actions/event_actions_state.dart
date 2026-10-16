part of 'event_actions_bloc.dart';

/// Отмена, которая ждёт отправки (виден снекбар «Вернуть»).
final class PendingCancel extends Equatable {
  const PendingCancel({required this.occurrence, required this.scope});

  /// Вхождение в том виде, в каком оно было до отмены (по нему делается откат).
  final ScheduleEventModel occurrence;
  final OccurrenceScope scope;

  @override
  List<Object?> get props => [occurrence, scope];
}

/// Состояние блока: [pending] — отложенная отмена, [effect] — одноразовое указание экрану.
///
/// Эффект обрабатывается в `BlocListener`; `EventActionEffect.id` делает каждый следующий эффект
/// отличным от предыдущего, поэтому одинаковые подряд идущие эффекты не теряются.
final class EventActionsState extends Equatable {
  const EventActionsState({this.pending, this.effect});

  const EventActionsState.idle() : this();

  final PendingCancel? pending;
  final EventActionEffect? effect;

  @override
  List<Object?> get props => [pending, effect];
}

/// Что экрану нужно сделать со списком и снекбаром. В каждом эффекте [occurrence] — вхождение
/// до действия, `scope` — область отмены.
sealed class EventActionEffect extends Equatable {
  const EventActionEffect({required this.id, required this.occurrence});

  final int id;
  final ScheduleEventModel occurrence;

  @override
  List<Object?> get props => [id, occurrence];
}

/// Отмена принята: пометить вхождение отменённым (при [OccurrenceScope.future] убрать следующие
/// вхождения серии) и показать снекбар с «Вернуть».
final class EventActionEffect$CancelApplied extends EventActionEffect {
  const EventActionEffect$CancelApplied({
    required super.id,
    required super.occurrence,
    required this.scope,
  });

  final OccurrenceScope scope;

  @override
  List<Object?> get props => [...super.props, scope];
}

/// «Вернуть» нажато до отправки: откатить список, запрос не уходил.
final class EventActionEffect$CancelUndone extends EventActionEffect {
  const EventActionEffect$CancelUndone({
    required super.id,
    required super.occurrence,
    required this.scope,
  });

  final OccurrenceScope scope;

  @override
  List<Object?> get props => [...super.props, scope];
}

/// Сервер принял отмену. При [OccurrenceScope.future] окно событий нужно перезагрузить.
final class EventActionEffect$CancelCommitted extends EventActionEffect {
  const EventActionEffect$CancelCommitted({
    required super.id,
    required super.occurrence,
    required this.scope,
    required this.event,
  });

  final OccurrenceScope scope;

  /// Вхождение в ответе сервера.
  final ScheduleEventModel event;

  @override
  List<Object?> get props => [...super.props, scope, event];
}

/// Отмена не удалась: откатить список и показать «Не удалось отменить. Повторить».
final class EventActionEffect$CancelFailed extends EventActionEffect {
  const EventActionEffect$CancelFailed({
    required super.id,
    required super.occurrence,
    required this.scope,
  });

  final OccurrenceScope scope;

  @override
  List<Object?> get props => [...super.props, scope];
}

/// Возврат принят: пометить вхождение запланированным.
final class EventActionEffect$RestoreApplied extends EventActionEffect {
  const EventActionEffect$RestoreApplied({required super.id, required super.occurrence});
}

/// Сервер принял возврат.
final class EventActionEffect$RestoreCommitted extends EventActionEffect {
  const EventActionEffect$RestoreCommitted({
    required super.id,
    required super.occurrence,
    required this.event,
  });

  final ScheduleEventModel event;

  @override
  List<Object?> get props => [...super.props, event];
}

/// Возврат не удалось отправить: снова пометить вхождение отменённым и показать ошибку.
final class EventActionEffect$RestoreFailed extends EventActionEffect {
  const EventActionEffect$RestoreFailed({required super.id, required super.occurrence});
}
