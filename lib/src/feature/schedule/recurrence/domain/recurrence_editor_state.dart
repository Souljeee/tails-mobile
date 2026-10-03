part of 'recurrence_editor_bloc.dart';

final class RecurrenceEditorState extends Equatable {
  const RecurrenceEditorState(this.draft);

  final RecurrenceDraft draft;

  @override
  List<Object?> get props => [draft];
}
