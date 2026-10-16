import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/event_action_rules.dart';

ScheduleEventModel _event({bool done = false, bool cancelled = false, bool recurring = false}) =>
    ScheduleEventModel(
      id: 'e1',
      petId: 1,
      title: 'Таблетки',
      type: ScheduleEventTypeEnum.dailyPills,
      done: done,
      cancelled: cancelled,
      date: DateTime(2026, 10, 8),
      recurrence: recurring ? const RecurrenceModel(period: RecurrencePeriod.day) : null,
    );

void main() {
  test('запланированное можно изменить и отменить', () {
    expect(EventActionRules.available(_event()), [EventAction.edit, EventAction.cancel]);
  });

  test('выполненное: снять отметку и изменить, отмена недоступна', () {
    final actions = EventActionRules.available(_event(done: true));

    expect(actions, [EventAction.unmarkDone, EventAction.edit]);
    expect(actions, isNot(contains(EventAction.cancel)));
  });

  test('отменённое одиночное событие можно вернуть', () {
    expect(EventActionRules.available(_event(cancelled: true)), [EventAction.restore]);
  });

  test('у отменённого вхождения серии действий нет', () {
    expect(EventActionRules.available(_event(cancelled: true, recurring: true)), isEmpty);
  });

  test('отмена главнее отметки выполнения', () {
    expect(EventActionRules.available(_event(done: true, cancelled: true)), [EventAction.restore]);
  });

  test('isAvailable', () {
    expect(EventActionRules.isAvailable(_event(), EventAction.cancel), isTrue);
    expect(EventActionRules.isAvailable(_event(done: true), EventAction.cancel), isFalse);
  });
}
