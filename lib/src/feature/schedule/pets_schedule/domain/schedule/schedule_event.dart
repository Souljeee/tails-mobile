part of 'schedule_bloc.dart';

typedef ScheduleEventMatch<T, S extends ScheduleEvent> = T Function(S event);

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  const factory ScheduleEvent.fetchRequested({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
  }) = ScheduleEvent$FetchRequested;

  const factory ScheduleEvent.loadMoreRequested({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
  }) = ScheduleEvent$LoadMoreRequested;

  const factory ScheduleEvent.markDoneRequested({
    required String eventId,
    required DateTime date,
    required bool value,
  }) = ScheduleEvent$MarkDoneRequested;

  T map<T>({
    required ScheduleEventMatch<T, ScheduleEvent$FetchRequested> fetchRequested,
    required ScheduleEventMatch<T, ScheduleEvent$LoadMoreRequested> loadMoreRequested,
    required ScheduleEventMatch<T, ScheduleEvent$MarkDoneRequested> markDoneRequested,
  }) => switch (this) {
    final ScheduleEvent$FetchRequested event => fetchRequested(event),
    final ScheduleEvent$LoadMoreRequested event => loadMoreRequested(event),
    final ScheduleEvent$MarkDoneRequested event => markDoneRequested(event),
  };
}

final class ScheduleEvent$FetchRequested extends ScheduleEvent {
  final DateTime startDate;
  final DateTime endDate;
  final int? petId;

  const ScheduleEvent$FetchRequested({required this.startDate, required this.endDate, this.petId});

  @override
  List<Object?> get props => [startDate, endDate, petId];
}

final class ScheduleEvent$LoadMoreRequested extends ScheduleEvent {
  final DateTime startDate;
  final DateTime endDate;
  final int? petId;

  const ScheduleEvent$LoadMoreRequested({
    required this.startDate,
    required this.endDate,
    this.petId,
  });

  @override
  List<Object?> get props => [startDate, endDate, petId];
}

final class ScheduleEvent$MarkDoneRequested extends ScheduleEvent {
  final String eventId;
  final DateTime date;
  final bool value;

  const ScheduleEvent$MarkDoneRequested({
    required this.eventId,
    required this.date,
    required this.value,
  });

  @override
  List<Object?> get props => [eventId, date, value];
}
