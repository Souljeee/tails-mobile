import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/constant/enums/pagination_status_enum.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/core/utils/extensions/date_time_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_occurrence_ref.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository _scheduleRepository;

  ScheduleBloc({required ScheduleRepository scheduleRepository})
    : _scheduleRepository = scheduleRepository,
      super(const ScheduleState.loading()) {
    on<ScheduleEvent>(
      (event, emit) => event.map(
        fetchRequested: (event) => _onFetchRequested(event, emit),
        loadMoreRequested: (event) => _onLoadMoreRequested(event, emit),
        markDoneRequested: (event) => _onMarkDoneRequested(event, emit),
        occurrenceCancelledChanged: (event) => _onOccurrenceCancelledChanged(event, emit),
        occurrenceReplaced: (event) => _onOccurrenceReplaced(event, emit),
        refreshRequested: (event) => _onRefreshRequested(event, emit),
      ),
    );
  }

  /// Параметры последней загрузки окна: по ним работает [ScheduleEvent.refreshRequested].
  ScheduleEvent$FetchRequested? _lastFetch;

  Future<void> _onFetchRequested(
    ScheduleEvent$FetchRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    _lastFetch = event;

    final hasData = state is ScheduleState$Success;
    final keepData = event.silent && hasData;

    try {
      if (!keepData) {
        emit(const ScheduleState.loading());
      }

      final ScheduleEventModelList scheduleEvents = await _scheduleRepository.getScheduleEvents(
        startDate: event.startDate,
        endDate: event.endDate,
        petId: event.petId,
      );

      // Окно данных ограничено, поэтому отсутствие повторов ничего не доказывает:
      // свойство только включается.
      if (scheduleEvents.values.any((day) => day.any((item) => item.recurrence != null))) {
        TailsAnalytics.setUserProperty(TailsAnalyticsUserProperty.hasRecurringEvents, true);
      }

      emit(ScheduleState.success(scheduleEvents: scheduleEvents));
    } catch (e, s) {
      addError(e, s);

      // При тихом обновлении оставляем уже показанные данные.
      if (!keepData) {
        emit(const ScheduleState.error());
      }
    } finally {
      event.completer?.complete();
    }
  }

  Future<void> _onLoadMoreRequested(
    ScheduleEvent$LoadMoreRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    await state.mapOrNull(
      success: (state) async {
        try {
          emit(
            state.copyWith(
              paginationStatus: const CopyWithWrapper.value(PaginationStatusEnum.loading),
            ),
          );

          final scheduleEvents = await _scheduleRepository.getScheduleEvents(
            startDate: event.startDate,
            endDate: event.endDate,
            petId: event.petId,
          );

          emit(
            state.copyWith(
              scheduleEvents: CopyWithWrapper.value(scheduleEvents),
              paginationStatus: const CopyWithWrapper.value(PaginationStatusEnum.idle),
            ),
          );
        } catch (e, s) {
          addError(e, s);

          emit(
            state.copyWith(
              paginationStatus: const CopyWithWrapper.value(PaginationStatusEnum.error),
            ),
          );
        }
      },
    );
  }

  Future<void> _onMarkDoneRequested(
    ScheduleEvent$MarkDoneRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    await state.mapOrNull(
      success: (state) async {
        final Map<DateTime, List<ScheduleEventModel>> updatedEventsMap = Map.from(
          state.scheduleEvents,
        );

        final events = updatedEventsMap[event.date] ?? [];

        final List<ScheduleEventModel> updatedEvents = [];

        for (final scheduleEvent in events) {
          if (scheduleEvent.id == event.eventId &&
              scheduleEvent.date.isSameDate(event.date) &&
              scheduleEvent.time == event.time) {
            final newScheduleEvent = scheduleEvent.copyWith(
              done: CopyWithWrapper.value(event.value),
            );

            updatedEvents.add(newScheduleEvent);
          } else {
            updatedEvents.add(scheduleEvent);
          }
        }

        updatedEventsMap[event.date] = updatedEvents;

        emit(state.copyWith(scheduleEvents: CopyWithWrapper.value(updatedEventsMap)));
      },
    );
  }

  Future<void> _onOccurrenceCancelledChanged(
    ScheduleEvent$OccurrenceCancelledChanged event,
    Emitter<ScheduleState> emit,
  ) async {
    final current = state;
    if (current is! ScheduleState$Success) {
      return;
    }

    final ref = event.ref;
    final updated = <DateTime, List<ScheduleEventModel>>{};

    current.scheduleEvents.forEach((day, items) {
      final next = <ScheduleEventModel>[];

      for (final item in items) {
        if (item.id != ref.eventId) {
          next.add(item);
        } else if (event.dropFollowing && item.date.isAfter(ref.date)) {
          // Остановленная серия: вхождения после даты отмены исчезают.
          continue;
        } else if (_isSameOccurrence(item, ref)) {
          next.add(item.copyWith(cancelled: CopyWithWrapper.value(event.cancelled)));
        } else {
          next.add(item);
        }
      }

      updated[day] = next;
    });

    emit(current.copyWith(scheduleEvents: CopyWithWrapper.value(updated)));
  }

  Future<void> _onOccurrenceReplaced(
    ScheduleEvent$OccurrenceReplaced event,
    Emitter<ScheduleState> emit,
  ) async {
    final current = state;
    if (current is! ScheduleState$Success) {
      return;
    }

    final replacement = event.occurrence;
    final updated = <DateTime, List<ScheduleEventModel>>{};

    current.scheduleEvents.forEach((day, items) {
      updated[day] = [
        for (final item in items) _isSameOccurrence(item, replacement.ref) ? replacement : item,
      ];
    });

    emit(current.copyWith(scheduleEvents: CopyWithWrapper.value(updated)));
  }

  Future<void> _onRefreshRequested(
    ScheduleEvent$RefreshRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    final last = _lastFetch;
    if (last == null) {
      event.completer?.complete();

      return;
    }

    await _onFetchRequested(
      ScheduleEvent$FetchRequested(
        startDate: last.startDate,
        endDate: last.endDate,
        petId: last.petId,
        silent: true,
        completer: event.completer,
      ),
      emit,
    );
  }

  bool _isSameOccurrence(ScheduleEventModel item, EventOccurrenceRef ref) =>
      item.id == ref.eventId && item.date.isSameDate(ref.date) && item.time == ref.time;
}
