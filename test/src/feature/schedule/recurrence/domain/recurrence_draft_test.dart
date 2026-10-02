import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_calculator.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';

void main() {
  // Суббота 26.09.2026
  final eventDate = DateTime(2026, 9, 26);
  RecurrenceDraft initial({String? time = '17:05'}) =>
      RecurrenceDraft.initial(eventDate: eventDate, eventTime: time);

  group('значения по умолчанию', () {
    test('берутся из даты и времени события', () {
      final draft = initial();

      expect(draft.period, RecurrencePeriod.day);
      expect(draft.weekDays, [6]);
      expect(draft.monthDays, [const MonthDay(26)]);
      expect(draft.yearDates, [const YearDate(9, 26)]);
      expect(draft.times, [const LocalTime(17, 5)]);
    });

    test('без времени события времена в день недоступны', () {
      final draft = initial(time: null);

      expect(draft.supportsTimes, isFalse);
      expect(draft.withTimesCount(3).times, isEmpty);
    });
  });

  group('периоды и интервал', () {
    test('переключение периода не стирает настройки других периодов', () {
      var draft = initial().withPeriod(RecurrencePeriod.week).toggleWeekDay(1).withInterval(2);
      draft = draft.withPeriod(RecurrencePeriod.month).toggleMonthDay(MonthDay.last);
      draft = draft.withPeriod(RecurrencePeriod.week);

      expect(draft.weekDays, [1, 6]);
      expect(draft.interval, 2);
      expect(draft.withPeriod(RecurrencePeriod.month).interval, 1);
    });

    test('интервал ограничен по периодам', () {
      expect(initial().withInterval(99).interval, 30);
      expect(initial().withPeriod(RecurrencePeriod.week).withInterval(99).interval, 12);
      expect(initial().withPeriod(RecurrencePeriod.month).withInterval(99).interval, 12);
      expect(initial().withPeriod(RecurrencePeriod.year).withInterval(99).interval, 10);
      expect(initial().withInterval(0).interval, 1);
    });

    test('в модель уходит только выбранный период', () {
      final model = initial()
          .withPeriod(RecurrencePeriod.week)
          .toggleWeekDay(1)
          .withPeriod(RecurrencePeriod.month)
          .toModel();

      expect(model.period, RecurrencePeriod.month);
      expect(model.weekDays, isEmpty);
      expect(model.monthDays, [const MonthDay(26)]);
    });
  });

  group('дни недели', () {
    test('последний выбранный день снять нельзя', () {
      final draft = initial().withPeriod(RecurrencePeriod.week);

      expect(draft.toggleWeekDay(6).weekDays, [6]);
    });

    test('пресеты', () {
      final draft = initial().withPeriod(RecurrencePeriod.week);

      expect(draft.withWeekdaysPreset().weekDays, [1, 2, 3, 4, 5]);
      expect(draft.withWeekdaysPreset().isWeekdaysPreset, isTrue);
      expect(draft.withWeekendPreset().weekDays, [6, 7]);
      expect(draft.withAllDaysPreset().isAllDaysPreset, isTrue);
    });

    test('дни остаются отсортированными', () {
      final draft = initial().withPeriod(RecurrencePeriod.week).toggleWeekDay(2).toggleWeekDay(1);

      expect(draft.weekDays, [1, 2, 6]);
    });
  });

  group('числа месяца и даты года', () {
    test('«последний день» всегда в конце и не снимается последним', () {
      var draft = initial().withPeriod(RecurrencePeriod.month).toggleMonthDay(MonthDay.last);
      draft = draft.toggleMonthDay(const MonthDay(5));

      expect(draft.monthDays, [const MonthDay(5), const MonthDay(26), MonthDay.last]);
      expect(
        draft
            .toggleMonthDay(MonthDay.last)
            .toggleMonthDay(const MonthDay(5))
            .toggleMonthDay(const MonthDay(26))
            .monthDays,
        [const MonthDay(26)],
      );
    });

    test('подсказка про перенос 29–31', () {
      final draft = initial().withPeriod(RecurrencePeriod.month);

      expect(draft.hasMonthTransfer, isFalse);
      expect(draft.toggleMonthDay(const MonthDay(31)).hasMonthTransfer, isTrue);
      expect(draft.toggleMonthDay(MonthDay.last).hasMonthTransfer, isFalse);
    });

    test('даты года: добавление, замена со слиянием, последняя не снимается, подсказка 29.02', () {
      var draft = initial().withPeriod(RecurrencePeriod.year);

      expect(draft.toggleYearDate(const YearDate(9, 26)).yearDates, [const YearDate(9, 26)]);
      draft = draft.toggleYearDate(const YearDate(3, 15));
      expect(draft.yearDates, [const YearDate(3, 15), const YearDate(9, 26)]);
      expect(draft.replaceYearDate(const YearDate(3, 15), const YearDate(9, 26)).yearDates, [
        const YearDate(9, 26),
      ]);
      expect(draft.hasFeb29, isFalse);
      expect(draft.replaceYearDate(const YearDate(3, 15), const YearDate(2, 29)).hasFeb29, isTrue);
    });
  });

  group('времена в день', () {
    test('автораскладка при смене счётчика', () {
      final draft = initial();

      expect(draft.withTimesCount(2).times, [const LocalTime(9, 0), const LocalTime(21, 0)]);
      expect(draft.withTimesCount(3).times, [
        const LocalTime(8, 0),
        const LocalTime(14, 0),
        const LocalTime(20, 0),
      ]);
      expect(draft.withTimesCount(4).times.length, 4);
      expect(draft.withTimesCount(6).times.length, 6);
      expect(draft.withTimesCount(3).withTimesCount(1).times, [const LocalTime(17, 5)]);
      expect(draft.withTimesCount(9).timesCount, 6);
    });

    test('после ручной правки «+» добавляет время через 2 часа, «−» убирает последнее', () {
      var draft = initial().withTimesCount(2).withTimeAt(0, const LocalTime(10, 0));

      draft = draft.withTimesCount(3);
      expect(draft.times, [const LocalTime(10, 0), const LocalTime(21, 0), const LocalTime(23, 0)]);

      draft = draft.withTimesCount(2);
      expect(draft.times, [const LocalTime(10, 0), const LocalTime(21, 0)]);
    });

    test('правка сортирует и сливает совпавшие времена, последнее удалить нельзя', () {
      var draft = initial().withTimesCount(3).withTimeAt(2, const LocalTime(7, 0));
      expect(draft.times, [const LocalTime(7, 0), const LocalTime(8, 0), const LocalTime(14, 0)]);

      draft = draft.withTimeAt(0, const LocalTime(14, 0));
      expect(draft.times, [const LocalTime(8, 0), const LocalTime(14, 0)]);

      draft = draft.removeTimeAt(0);
      expect(draft.times, [const LocalTime(14, 0)]);
      expect(draft.removeTimeAt(0).times, [const LocalTime(14, 0)]);
    });

    test('в модель несколько времён попадают только для периода «День»', () {
      final draft = initial().withTimesCount(2);

      expect(draft.toModel().times.length, 2);
      expect(draft.withPeriod(RecurrencePeriod.week).toModel().times, isEmpty);
      expect(initial().toModel().times, isEmpty);
    });

    test('время события после сохранения — первое из времён', () {
      expect(initial().withTimesCount(2).resultingEventTime, '09:00');
      expect(
        initial().withPeriod(RecurrencePeriod.week).withTimesCount(2).resultingEventTime,
        '17:05',
      );
      expect(initial(time: null).resultingEventTime, isNull);
    });
  });

  group('окончание', () {
    test('число повторений в пределах 2–999', () {
      expect(initial().withEndCount(1).end, const RecurrenceEnd.afterCount(2));
      expect(initial().withEndCount(5000).end, const RecurrenceEnd.afterCount(999));
      expect(initial().withEndCount(7).canSave, isTrue);
    });

    test('дата окончания раньше события или первого повторения — ошибка', () {
      final week = initial().withPeriod(RecurrencePeriod.week).toggleWeekDay(2).toggleWeekDay(6);

      expect(
        week.withEnd(RecurrenceEnd.until(DateTime(2026, 9, 20))).endError,
        isA<RecurrenceEndError$BeforeStart>(),
      );
      // событие в субботу, повторение по вторникам: первое повторение 29.09
      expect(
        week.withEnd(RecurrenceEnd.until(DateTime(2026, 9, 28))).endError,
        isA<RecurrenceEndError$BeforeFirst>(),
      );
      expect(week.withEnd(RecurrenceEnd.until(DateTime(2026, 9, 28))).canSave, isFalse);
      expect(week.withEnd(RecurrenceEnd.until(DateTime(2026, 9, 29))).canSave, isTrue);
    });
  });

  group('привязка к событию', () {
    test('rebase обновляет нетронутые значения и не трогает настройки пользователя', () {
      var draft = initial().withPeriod(RecurrencePeriod.week).toggleWeekDay(1);
      draft = draft.rebase(eventDate: DateTime(2026, 10, 1), eventTime: '09:00');

      expect(draft.weekDays, [1, 6]); // правили вручную
      expect(draft.monthDays, [const MonthDay(1)]); // нетронутое — обновилось
      expect(draft.yearDates, [const YearDate(10, 1)]);
      expect(draft.times, [const LocalTime(9, 0)]);
    });

    test('rebase пересчитывает автораскладку и убирает времена при «весь день»', () {
      final draft = initial().withTimesCount(3);

      expect(draft.rebase(eventDate: eventDate, eventTime: '10:00').times.length, 3);
      expect(draft.rebase(eventDate: eventDate, eventTime: null).times, isEmpty);
      expect(draft.rebase(eventDate: eventDate, eventTime: null).supportsTimes, isFalse);
    });
  });

  test('черновик из существующего правила', () {
    const rule = RecurrenceModel(
      period: RecurrencePeriod.week,
      interval: 2,
      weekDays: [2, 4],
      end: RecurrenceEnd.afterCount(5),
    );

    final draft = RecurrenceDraft.fromModel(rule, eventDate: eventDate, eventTime: '17:05');

    expect(draft.period, RecurrencePeriod.week);
    expect(draft.interval, 2);
    expect(draft.weekDays, [2, 4]);
    expect(draft.toModel(), rule);
  });
}
