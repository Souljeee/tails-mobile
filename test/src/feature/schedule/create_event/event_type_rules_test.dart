import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/event_title_rules.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/event_type_rules.dart';

void main() {
  group('EventTypeRules.apiType', () {
    RecurrenceModel rule(RecurrencePeriod period, {int interval = 1}) =>
        RecurrenceModel(period: period, interval: interval);

    test('лекарства «каждый день» — dailyPills', () {
      expect(
        EventTypeRules.apiType(ScheduleEventTypeEnum.dailyPills, rule(RecurrencePeriod.day)),
        ScheduleEventTypeEnum.dailyPills,
      );
    });

    test('лекарства с любым другим расписанием — weeklyPills', () {
      for (final recurrence in [
        rule(RecurrencePeriod.day, interval: 2),
        rule(RecurrencePeriod.week),
        rule(RecurrencePeriod.month),
        null,
      ]) {
        expect(
          EventTypeRules.apiType(ScheduleEventTypeEnum.dailyPills, recurrence),
          ScheduleEventTypeEnum.weeklyPills,
        );
      }
    });

    test('остальные типы уходят как есть', () {
      expect(
        EventTypeRules.apiType(ScheduleEventTypeEnum.walking, rule(RecurrencePeriod.week)),
        ScheduleEventTypeEnum.walking,
      );
      expect(
        EventTypeRules.apiType(ScheduleEventTypeEnum.custom, null),
        ScheduleEventTypeEnum.custom,
      );
    });
  });

  test('повторение по типу: год для вакцинации, день для лекарств, иначе нет', () {
    expect(
      EventTypeRules.defaultPeriod(ScheduleEventTypeEnum.yearlyVaccination),
      RecurrencePeriod.year,
    );
    expect(EventTypeRules.defaultPeriod(ScheduleEventTypeEnum.dailyPills), RecurrencePeriod.day);
    expect(EventTypeRules.defaultPeriod(ScheduleEventTypeEnum.weeklyPills), RecurrencePeriod.day);
    expect(EventTypeRules.defaultPeriod(ScheduleEventTypeEnum.rabiesVaccination), isNull);
    expect(EventTypeRules.defaultPeriod(ScheduleEventTypeEnum.walking), isNull);
  });

  group('EventTitleRules.onTypeSelected', () {
    EventTitleAction run({
      String current = '',
      bool autofilled = false,
      ScheduleEventTypeEnum? previous,
      ScheduleEventTypeEnum type = ScheduleEventTypeEnum.walking,
      String name = 'Прогулка',
    }) => EventTitleRules.onTypeSelected(
      current: current,
      autofilled: autofilled,
      previousType: previous,
      newType: type,
      typeName: name,
    );

    test('пустое название подставляется из типа', () {
      expect(run(), EventTitleAction.fill);
      expect(run(current: '  '), EventTitleAction.fill);
    });

    test('подставленное название меняется на новое', () {
      expect(
        run(current: 'Прогулка', autofilled: true, previous: ScheduleEventTypeEnum.walking),
        EventTitleAction.fill,
      );
    });

    test('своё название не трогаем, после смены типа предлагаем заменить', () {
      expect(
        run(current: 'Вечерний круг', previous: ScheduleEventTypeEnum.feeding),
        EventTitleAction.suggest,
      );
    });

    test('своё название при первом выборе типа или том же типе остаётся тихо', () {
      expect(run(current: 'Вечерний круг'), EventTitleAction.keep);
      expect(
        run(current: 'Вечерний круг', previous: ScheduleEventTypeEnum.walking),
        EventTitleAction.keep,
      );
    });

    test('название уже совпадает с названием типа — ничего не предлагаем', () {
      expect(
        run(current: 'Прогулка', previous: ScheduleEventTypeEnum.feeding),
        EventTitleAction.keep,
      );
    });

    test('«Другое» очищает только подставленное название', () {
      expect(
        run(
          current: 'Прогулка',
          autofilled: true,
          type: ScheduleEventTypeEnum.custom,
          name: 'Другое',
        ),
        EventTitleAction.clear,
      );
      expect(
        run(current: 'Своё', type: ScheduleEventTypeEnum.custom, name: 'Другое'),
        EventTitleAction.keep,
      );
      expect(run(type: ScheduleEventTypeEnum.custom, name: 'Другое'), EventTitleAction.keep);
    });
  });
}
