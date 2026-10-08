import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';

part 'mark_done_event.dart';
part 'mark_done_state.dart';

class MarkDoneBloc extends Bloc<MarkDoneEvent, MarkDoneState> {
  final ScheduleRepository _scheduleRepository;

  MarkDoneBloc({required ScheduleRepository scheduleRepository})
    : _scheduleRepository = scheduleRepository,
      super(const MarkDoneState.idle()) {
    on<MarkDoneEvent>(
      (event, emit) => event.map(markDoneRequested: (event) => _onMarkDoneRequested(event, emit)),
    );
  }

  Future<void> _onMarkDoneRequested(
    MarkDoneEvent$MarkDoneRequested event,
    Emitter<MarkDoneState> emit,
  ) async {
    try {
      emit(const MarkDoneState.loading());

      await _scheduleRepository.updateEventDoneStatus(
        value: event.value,
        eventId: event.eventId,
        date: event.date,
        time: event.time,
        timeZoneOffset: event.timeZoneOffset,
      );

      final eventType = event.analyticsEventType;
      if (eventType != null) {
        TailsAnalytics.log(
          event.value
              ? TailsAnalyticsEvents.eventMarkedDone(
                  eventType: eventType,
                  isRecurring: event.analyticsIsRecurring,
                  from: event.analyticsFrom,
                )
              : TailsAnalyticsEvents.eventMarkedUndone(eventType: eventType),
        );
      }

      emit(const MarkDoneState.success());
    } catch (e, s) {
      addError(e, s);

      emit(const MarkDoneState.error());
    } finally {
      emit(const MarkDoneState.idle());
    }
  }
}
