part of 'mark_done_bloc.dart';

typedef MarkDoneEventMatch<T, S extends MarkDoneEvent> = T Function(S event);

sealed class MarkDoneEvent extends Equatable {
  const MarkDoneEvent();

  const factory MarkDoneEvent.markDoneRequested({
    required String eventId,
    required DateTime date,
    required bool value,
  }) = MarkDoneEvent$MarkDoneRequested;

  T map<T>({required MarkDoneEventMatch<T, MarkDoneEvent$MarkDoneRequested> markDoneRequested}) =>
      switch (this) {
        final MarkDoneEvent$MarkDoneRequested event => markDoneRequested(event),
      };
}

final class MarkDoneEvent$MarkDoneRequested extends MarkDoneEvent {
  final bool value;
  final String eventId;
  final DateTime date;
  const MarkDoneEvent$MarkDoneRequested({
    required this.value,
    required this.eventId,
    required this.date,
  });

  @override
  List<Object?> get props => [value, eventId, date];
}
