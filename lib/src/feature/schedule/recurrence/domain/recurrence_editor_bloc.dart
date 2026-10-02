import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';

part 'recurrence_editor_event.dart';
part 'recurrence_editor_state.dart';

/// Состояние экрана «Повторение»: хранит [RecurrenceDraft]; правила правок живут в самом
/// черновике, блок лишь принимает новое значение и пересчитывает значения по умолчанию.
class RecurrenceEditorBloc extends Bloc<RecurrenceEditorEvent, RecurrenceEditorState> {
  RecurrenceEditorBloc({required RecurrenceDraft draft}) : super(RecurrenceEditorState(draft)) {
    on<RecurrenceEditorEvent>(
      (event, emit) => event.map(
        changed: (event) => emit(RecurrenceEditorState(event.draft)),
        eventChanged: (event) => emit(
          RecurrenceEditorState(
            state.draft.rebase(eventDate: event.eventDate, eventTime: event.eventTime),
          ),
        ),
      ),
    );
  }
}
