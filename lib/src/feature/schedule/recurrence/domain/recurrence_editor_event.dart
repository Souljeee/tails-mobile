part of 'recurrence_editor_bloc.dart';

typedef RecurrenceEditorEventMatch<T, S extends RecurrenceEditorEvent> = T Function(S event);

sealed class RecurrenceEditorEvent extends Equatable {
  const RecurrenceEditorEvent();

  /// Пользователь изменил черновик.
  const factory RecurrenceEditorEvent.changed(RecurrenceDraft draft) =
      RecurrenceEditorEvent$Changed;

  /// У события изменились дата или время: обновить значения по умолчанию.
  const factory RecurrenceEditorEvent.eventChanged({
    required DateTime eventDate,
    String? eventTime,
  }) = RecurrenceEditorEvent$EventChanged;

  T map<T>({
    required RecurrenceEditorEventMatch<T, RecurrenceEditorEvent$Changed> changed,
    required RecurrenceEditorEventMatch<T, RecurrenceEditorEvent$EventChanged> eventChanged,
  }) => switch (this) {
    final RecurrenceEditorEvent$Changed event => changed(event),
    final RecurrenceEditorEvent$EventChanged event => eventChanged(event),
  };
}

final class RecurrenceEditorEvent$Changed extends RecurrenceEditorEvent {
  const RecurrenceEditorEvent$Changed(this.draft);

  final RecurrenceDraft draft;

  @override
  List<Object?> get props => [draft];
}

final class RecurrenceEditorEvent$EventChanged extends RecurrenceEditorEvent {
  const RecurrenceEditorEvent$EventChanged({required this.eventDate, this.eventTime});

  final DateTime eventDate;
  final String? eventTime;

  @override
  List<Object?> get props => [eventDate, eventTime];
}
