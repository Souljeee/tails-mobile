part of 'mark_done_bloc.dart';

typedef MarkDoneEventMatch<T, S extends MarkDoneEvent> = T Function(S event);

sealed class MarkDoneEvent extends Equatable {
  const MarkDoneEvent();

  const factory MarkDoneEvent.markDoneRequested({required String eventId, required DateTime date}) = MarkDoneEvent$MarkDoneRequested;

  T map<T>({
    required MarkDoneEventMatch<T, MarkDoneEvent$MarkDoneRequested> markDoneRequested,
  }) =>
      switch (this) {
        final MarkDoneEvent$MarkDoneRequested event => markDoneRequested(event),
      };
}

final class MarkDoneEvent$MarkDoneRequested extends MarkDoneEvent {
  final String eventId;
  final DateTime date;
  const MarkDoneEvent$MarkDoneRequested({required this.eventId, required this.date});

  @override
  List<Object?> get props => [eventId, date];
}