import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_editor_bloc.dart';

void main() {
  final initial = RecurrenceDraft.initial(eventDate: DateTime(2026, 10, 5), eventTime: '09:00');

  test('changed подставляет новый черновик', () async {
    final bloc = RecurrenceEditorBloc(draft: initial);
    final changed = initial.withPeriod(RecurrencePeriod.week);

    bloc.add(RecurrenceEditorEvent.changed(changed));
    await bloc.stream.first;

    expect(bloc.state.draft, changed);
    await bloc.close();
  });

  test('eventChanged обновляет нетронутые значения по умолчанию', () async {
    final bloc = RecurrenceEditorBloc(draft: initial);

    bloc.add(
      RecurrenceEditorEvent.eventChanged(eventDate: DateTime(2026, 10, 7), eventTime: '09:00'),
    );
    await bloc.stream.first;

    expect(bloc.state.draft.weekDays, [3]);
    expect(bloc.state.draft.eventDate, DateTime(2026, 10, 7));
    await bloc.close();
  });
}
