part of 'edit_event_bloc.dart';

sealed class EditEventEvent extends Equatable {
  const EditEventEvent();

  const factory EditEventEvent.saveRequested({
    required ScheduleEventModel occurrence,
    required OccurrenceScope scope,
    required CreateEventModel model,
    required EditChanges changes,
  }) = EditEventEvent$SaveRequested;

  T map<T>({required T Function(EditEventEvent$SaveRequested event) saveRequested}) =>
      switch (this) {
        final EditEventEvent$SaveRequested event => saveRequested(event),
      };
}

final class EditEventEvent$SaveRequested extends EditEventEvent {
  const EditEventEvent$SaveRequested({
    required this.occurrence,
    required this.scope,
    required this.model,
    required this.changes,
  });

  final ScheduleEventModel occurrence;
  final OccurrenceScope scope;
  final CreateEventModel model;
  final EditChanges changes;

  @override
  List<Object?> get props => [occurrence, scope, model, changes];
}
