import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/feature/schedule/core/analytics/schedule_analytics.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';

part 'event_actions_event.dart';
part 'event_actions_state.dart';

/// Отмена и возврат вхождений (область экрана календаря).
///
/// Отмена оптимистична: экран сразу показывает новое состояние, а запрос откладывается на
/// [undoDelay], пока виден снекбар «Вернуть». «Вернуть» гасит таймер и откатывает без обращения
/// к серверу; закрытие снекбара, уход с экрана и сворачивание приложения отправляют запрос
/// немедленно. Ошибка откатывает состояние. Постоянной очереди нет: если систему убьёт процесс
/// до отправки, отмена теряется (решение D6 плана).
class EventActionsBloc extends Bloc<EventActionsEvent, EventActionsState> {
  EventActionsBloc({
    required ScheduleRepository scheduleRepository,
    this.undoDelay = const Duration(seconds: 6),
  }) : _scheduleRepository = scheduleRepository,
       super(const EventActionsState.idle()) {
    on<EventActionsEvent>(
      (event, emit) => event.map(
        cancelRequested: (event) => _onCancelRequested(event, emit),
        undoRequested: (event) => _onUndoRequested(event, emit),
        flushRequested: (event) => _onFlushRequested(event, emit),
        restoreRequested: (event) => _onRestoreRequested(event, emit),
      ),
      // Отмена, таймер и возврат меняют одно и то же: обрабатываем по очереди.
      transformer: sequential(),
    );
  }

  static const String _logSource = 'EventActionsBloc';

  final ScheduleRepository _scheduleRepository;

  /// Сколько отмена ждёт отправки (время показа снекбара).
  final Duration undoDelay;

  Timer? _timer;
  int _effectId = 0;

  /// Запрос отмены уже в пути: при закрытии блока второй раз его не отправляем.
  bool _committing = false;

  int get _nextEffectId => ++_effectId;

  Future<void> _onCancelRequested(
    EventActionsEvent$CancelRequested event,
    Emitter<EventActionsState> emit,
  ) async {
    // Две отмены подряд: первая уходит сразу, снекбар остаётся только у второй.
    await _commitPending(emit);

    final occurrence = event.occurrence;
    final pending = PendingCancel(occurrence: occurrence, scope: event.scope);

    _timer?.cancel();
    _timer = Timer(undoDelay, () {
      if (!isClosed) {
        add(const EventActionsEvent.flushRequested());
      }
    });

    TailsLogger.info(
      'Отмена вхождения принята, ждёт отправки',
      source: _logSource,
      data: {'scope': event.scope.apiValue, 'delay_ms': undoDelay.inMilliseconds},
    );

    emit(
      EventActionsState(
        pending: pending,
        effect: EventActionEffect$CancelApplied(
          id: _nextEffectId,
          occurrence: occurrence,
          scope: event.scope,
        ),
      ),
    );
  }

  Future<void> _onUndoRequested(
    EventActionsEvent$UndoRequested event,
    Emitter<EventActionsState> emit,
  ) async {
    final pending = state.pending;
    if (pending == null) {
      return;
    }

    _timer?.cancel();
    _timer = null;

    TailsAnalytics.log(TailsAnalyticsEvents.eventCancelUndone);
    TailsLogger.info('Отмена отозвана до отправки', source: _logSource);

    emit(
      EventActionsState(
        effect: EventActionEffect$CancelUndone(
          id: _nextEffectId,
          occurrence: pending.occurrence,
          scope: pending.scope,
        ),
      ),
    );
  }

  Future<void> _onFlushRequested(
    EventActionsEvent$FlushRequested event,
    Emitter<EventActionsState> emit,
  ) => _commitPending(emit);

  Future<void> _onRestoreRequested(
    EventActionsEvent$RestoreRequested event,
    Emitter<EventActionsState> emit,
  ) async {
    final occurrence = event.occurrence;
    final pending = state.pending;

    // Вернуть вхождение, отмена которого ещё не ушла, — то же самое, что «Вернуть» в снекбаре.
    if (pending != null && pending.occurrence.ref == occurrence.ref) {
      return _onUndoRequested(const EventActionsEvent$UndoRequested(), emit);
    }

    emit(
      EventActionsState(
        pending: pending,
        effect: EventActionEffect$RestoreApplied(id: _nextEffectId, occurrence: occurrence),
      ),
    );

    try {
      final updated = await _scheduleRepository.restoreOccurrence(occurrence.ref);

      TailsAnalytics.log(TailsAnalyticsEvents.eventRestored);
      TailsLogger.info('Вхождение возвращено в расписание', source: _logSource);

      emit(
        EventActionsState(
          pending: state.pending,
          effect: EventActionEffect$RestoreCommitted(
            id: _nextEffectId,
            occurrence: occurrence,
            event: updated,
          ),
        ),
      );
    } catch (e, s) {
      addError(e, s);

      emit(
        EventActionsState(
          pending: state.pending,
          effect: EventActionEffect$RestoreFailed(id: _nextEffectId, occurrence: occurrence),
        ),
      );
    }
  }

  /// Отправляет ожидающую отмену, если она есть.
  Future<void> _commitPending(Emitter<EventActionsState> emit) async {
    final pending = state.pending;
    if (pending == null) {
      return;
    }

    _timer?.cancel();
    _timer = null;

    final occurrence = pending.occurrence;
    final scope = pending.scope;

    _committing = true;
    try {
      final updated = await _scheduleRepository.cancelOccurrence(occurrence.ref, scope: scope);

      TailsAnalytics.log(
        TailsAnalyticsEvents.eventCancelled(
          scope: scope.apiValue,
          eventType: ScheduleAnalytics.eventType(occurrence.type),
          isRecurring: occurrence.recurrence != null,
        ),
      );
      TailsLogger.info(
        'Отмена вхождения отправлена',
        source: _logSource,
        data: {'scope': scope.apiValue},
      );

      emit(
        EventActionsState(
          effect: EventActionEffect$CancelCommitted(
            id: _nextEffectId,
            occurrence: occurrence,
            scope: scope,
            event: updated,
          ),
        ),
      );
    } catch (e, s) {
      addError(e, s);

      emit(
        EventActionsState(
          effect: EventActionEffect$CancelFailed(
            id: _nextEffectId,
            occurrence: occurrence,
            scope: scope,
          ),
        ),
      );
    } finally {
      _committing = false;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;

    // Экран закрыт, а отмена ещё не ушла: отправляем без возможности что-то показать.
    final pending = state.pending;
    if (pending != null && !_committing) {
      unawaited(_sendDetached(pending));
    }

    return super.close();
  }

  Future<void> _sendDetached(PendingCancel pending) async {
    try {
      await _scheduleRepository.cancelOccurrence(pending.occurrence.ref, scope: pending.scope);

      TailsAnalytics.log(
        TailsAnalyticsEvents.eventCancelled(
          scope: pending.scope.apiValue,
          eventType: ScheduleAnalytics.eventType(pending.occurrence.type),
          isRecurring: pending.occurrence.recurrence != null,
        ),
      );
    } catch (e, s) {
      TailsLogger.error(
        'Не удалось отправить отмену при закрытии экрана',
        source: _logSource,
        error: e,
        stackTrace: s,
      );
    }
  }
}
