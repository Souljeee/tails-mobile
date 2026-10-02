import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations_ru.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_summary.dart';

void main() {
  final builder = RecurrenceSummaryBuilder(AppLocalizationsRu());
  final start = DateTime(2026, 10, 5);

  RecurrenceSummary build(RecurrenceModel rule, {String? time = '17:05'}) =>
      builder.build(rule, start: start, eventTime: time);

  void expectSummary(
    RecurrenceModel rule,
    String title,
    String subtitle, {
    String? time = '17:05',
  }) {
    final summary = build(rule, time: time);
    expect(summary.title, title);
    expect(summary.subtitle, subtitle);
  }

  group('дни', () {
    test('каждый день и через день', () {
      expectSummary(const RecurrenceModel(period: RecurrencePeriod.day), 'Каждый день', 'в 17:05');
      expectSummary(
        const RecurrenceModel(period: RecurrencePeriod.day, interval: 2),
        'Через день',
        'в 17:05',
      );
    });

    test('склонение «каждые N дней»', () {
      const expected = {
        3: 'Каждые 3 дня',
        5: 'Каждые 5 дней',
        11: 'Каждые 11 дней',
        21: 'Каждый 21 день',
        22: 'Каждые 22 дня',
        25: 'Каждые 25 дней',
      };
      expected.forEach((n, text) {
        expect(build(RecurrenceModel(period: RecurrencePeriod.day, interval: n)).title, text);
      });
    });

    test('несколько времён в день', () {
      expectSummary(
        const RecurrenceModel(
          period: RecurrencePeriod.day,
          times: [LocalTime(8, 0), LocalTime(14, 0), LocalTime(20, 0)],
        ),
        '3 раза в день',
        '08:00 · 14:00 · 20:00',
      );
    });

    test('несколько времён в день при интервале 2', () {
      expectSummary(
        const RecurrenceModel(
          period: RecurrencePeriod.day,
          interval: 2,
          times: [LocalTime(9, 0), LocalTime(21, 0)],
        ),
        'Через день',
        '2 раза в день · в 09:00 и 21:00',
      );
    });

    test('без времени события подписи со временем нет', () {
      expectSummary(
        const RecurrenceModel(period: RecurrencePeriod.day),
        'Каждый день',
        '',
        time: null,
      );
    });
  });

  group('недели', () {
    test('по нескольким дням', () {
      expectSummary(
        const RecurrenceModel(period: RecurrencePeriod.week, weekDays: [1, 3, 5]),
        'По понедельникам, средам и пятницам',
        '3 раза в неделю · в 17:05',
      );
    });

    test('будни, выходные и все дни', () {
      expectSummary(
        const RecurrenceModel(period: RecurrencePeriod.week, weekDays: [1, 2, 3, 4, 5]),
        'По будням',
        '5 раз в неделю · в 17:05',
      );
      expectSummary(
        const RecurrenceModel(period: RecurrencePeriod.week, weekDays: [6, 7]),
        'По выходным',
        '2 раза в неделю · в 17:05',
      );
      expectSummary(
        const RecurrenceModel(period: RecurrencePeriod.week, weekDays: [1, 2, 3, 4, 5, 6, 7]),
        'Каждый день',
        '7 раз в неделю · в 17:05',
      );
    });

    test('один день недели с правильным родом', () {
      const expected = {
        1: 'Каждый понедельник',
        3: 'Каждую среду',
        5: 'Каждую пятницу',
        6: 'Каждую субботу',
        7: 'Каждое воскресенье',
      };
      expected.forEach((day, text) {
        final rule = RecurrenceModel(period: RecurrencePeriod.week, weekDays: [day]);
        expect(build(rule).title, text);
        expect(build(rule).subtitle, 'раз в неделю · в 17:05');
      });
    });

    test('каждые две недели с окончанием', () {
      expectSummary(
        RecurrenceModel(
          period: RecurrencePeriod.week,
          interval: 2,
          weekDays: const [2, 4],
          end: RecurrenceEnd.until(DateTime(2026, 12, 31)),
        ),
        'Каждые 2 недели по вторникам и четвергам',
        '2 раза за 2 недели · в 17:05 · до 31.12.2026',
      );
    });

    test('один день и интервал', () {
      expectSummary(
        const RecurrenceModel(period: RecurrencePeriod.week, interval: 3, weekDays: [2]),
        'Каждые 3 недели по вторникам',
        'раз в 3 недели · в 17:05',
      );
    });
  });

  group('месяцы', () {
    test('несколько чисел', () {
      expectSummary(
        const RecurrenceModel(
          period: RecurrencePeriod.month,
          monthDays: [MonthDay(5), MonthDay(15), MonthDay(25)],
        ),
        '5, 15 и 25 числа каждого месяца',
        '3 раза в месяц · в 17:05',
      );
    });

    test('последний день, в том числе с интервалом', () {
      expectSummary(
        const RecurrenceModel(period: RecurrencePeriod.month, monthDays: [MonthDay.last]),
        'В последний день каждого месяца',
        'раз в месяц · в 17:05',
      );
      expectSummary(
        const RecurrenceModel(
          period: RecurrencePeriod.month,
          interval: 3,
          monthDays: [MonthDay.last],
        ),
        'В последний день каждые 3 месяца',
        'раз в 3 месяца · в 17:05',
      );
    });

    test('числа вместе с последним днём', () {
      expectSummary(
        const RecurrenceModel(
          period: RecurrencePeriod.month,
          monthDays: [MonthDay(5), MonthDay(15), MonthDay.last],
        ),
        '5 и 15 числа и в последний день каждого месяца',
        '3 раза в месяц · в 17:05',
      );
    });
  });

  group('годы', () {
    test('несколько дат', () {
      expectSummary(
        const RecurrenceModel(
          period: RecurrencePeriod.year,
          yearDates: [YearDate(3, 15), YearDate(9, 15)],
        ),
        '15 марта и 15 сентября каждого года',
        '2 раза в год · в 17:05',
      );
    });

    test('29 февраля каждые 2 года', () {
      expectSummary(
        const RecurrenceModel(
          period: RecurrencePeriod.year,
          interval: 2,
          yearDates: [YearDate(2, 29)],
        ),
        '29 февраля, каждые 2 года',
        'раз в 2 года · в 17:05',
      );
    });

    test('одна дата каждый год', () {
      expectSummary(
        const RecurrenceModel(period: RecurrencePeriod.year, yearDates: [YearDate(3, 15)]),
        '15 марта каждого года',
        'раз в год · в 17:05',
      );
    });
  });

  test('«после N повторений» показывает вычисленную дату последнего', () {
    final summary = build(
      const RecurrenceModel(period: RecurrencePeriod.day, end: RecurrenceEnd.afterCount(5)),
    );

    expect(summary.subtitle, 'в 17:05 · после 5 повторений · до 09.10.2026');
  });

  test('склонение «после 21 повторения»', () {
    final summary = build(
      const RecurrenceModel(period: RecurrencePeriod.day, end: RecurrenceEnd.afterCount(21)),
    );

    expect(summary.subtitle, contains('после 21 повторения'));
  });
}
