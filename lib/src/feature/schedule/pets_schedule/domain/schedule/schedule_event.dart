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

  T map<T>({required ScheduleEventMatch<T, ScheduleEvent$FetchRequested> fetchRequested, required ScheduleEventMatch<T, ScheduleEvent$LoadMoreRequested> loadMoreRequested}) =>
      switch (this) {
        final ScheduleEvent$FetchRequested event => fetchRequested(event),
        final ScheduleEvent$LoadMoreRequested event => loadMoreRequested(event),
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

  const ScheduleEvent$LoadMoreRequested({required this.startDate, required this.endDate, this.petId});

  @override
  List<Object?> get props => [startDate, endDate, petId];
}
