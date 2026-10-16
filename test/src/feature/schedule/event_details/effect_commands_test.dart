import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/effect_commands.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/event_actions_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/schedule/schedule_bloc.dart';

void main() {
  final occurrence = ScheduleEventModel(
    id: 'e1',
    petId: 1,
    title: 'Таблетки',
    type: ScheduleEventTypeEnum.dailyPills,
    done: false,
    date: DateTime(2026, 10, 8),
  );
  final changed = occurrence.copyWith();

  List<Type> types(List<ScheduleEvent> commands) => commands.map((c) => c.runtimeType).toList();

  test('отмена одной даты помечает вхождение и не трогает серию', () {
    final commands = scheduleCommandsFor(
      EventActionEffect$CancelApplied(id: 1, occurrence: occurrence, scope: OccurrenceScope.one),
    );

    final command = commands.single as ScheduleEvent$OccurrenceCancelledChanged;
    expect(command.cancelled, isTrue);
    expect(command.dropFollowing, isFalse);
    expect(command.ref, occurrence.ref);
  });

  test('отмена «и все следующие» убирает вхождения серии', () {
    final commands = scheduleCommandsFor(
      EventActionEffect$CancelApplied(id: 1, occurrence: occurrence, scope: OccurrenceScope.future),
    );

    expect((commands.single as ScheduleEvent$OccurrenceCancelledChanged).dropFollowing, isTrue);
  });

  test('откат отмены серии перезагружает окно, откат одной даты нет', () {
    final one = scheduleCommandsFor(
      EventActionEffect$CancelUndone(id: 1, occurrence: occurrence, scope: OccurrenceScope.one),
    );
    final future = scheduleCommandsFor(
      EventActionEffect$CancelFailed(id: 2, occurrence: occurrence, scope: OccurrenceScope.future),
    );

    expect(types(one), [ScheduleEvent$OccurrenceCancelledChanged]);
    expect(types(future), [
      ScheduleEvent$OccurrenceCancelledChanged,
      ScheduleEvent$RefreshRequested,
    ]);
    expect((one.single as ScheduleEvent$OccurrenceCancelledChanged).cancelled, isFalse);
  });

  test('подтверждение отмены серии перезагружает окно, одной даты нет', () {
    expect(
      scheduleCommandsFor(
        EventActionEffect$CancelCommitted(
          id: 1,
          occurrence: occurrence,
          scope: OccurrenceScope.one,
          event: changed,
        ),
      ),
      isEmpty,
    );
    expect(
      types(
        scheduleCommandsFor(
          EventActionEffect$CancelCommitted(
            id: 2,
            occurrence: occurrence,
            scope: OccurrenceScope.future,
            event: changed,
          ),
        ),
      ),
      [ScheduleEvent$RefreshRequested],
    );
  });

  test('возврат: снимает отмену сразу и возвращает её при ошибке', () {
    final applied =
        scheduleCommandsFor(EventActionEffect$RestoreApplied(id: 1, occurrence: occurrence)).single
            as ScheduleEvent$OccurrenceCancelledChanged;
    final failed =
        scheduleCommandsFor(EventActionEffect$RestoreFailed(id: 2, occurrence: occurrence)).single
            as ScheduleEvent$OccurrenceCancelledChanged;

    expect(applied.cancelled, isFalse);
    expect(failed.cancelled, isTrue);
    expect(
      scheduleCommandsFor(
        EventActionEffect$RestoreCommitted(id: 3, occurrence: occurrence, event: changed),
      ),
      isEmpty,
    );
  });
}
