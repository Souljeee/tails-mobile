import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/recurrence_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/mappers/recurrence_mapper.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';

void main() {
  group('RecurrenceDto', () {
    test('разбирает ответ API со всеми полями и игнорирует лишние', () {
      final dto = RecurrenceDto.fromJson(const {
        'frequency': 'monthly',
        'interval': 2,
        'week_days': null,
        'month_days': [5, -1, 15],
        'year_dates': null,
        'times': null,
        'end_type': 'count',
        'end_date': null,
        'end_count': 5,
        'until': '2026-12-31',
        'новое_поле': true,
      });

      expect(dto.frequency, 'monthly');
      expect(dto.monthDays, [5, -1, 15]);
      expect(dto.endCount, 5);
    });

    test('interval по умолчанию 1', () {
      expect(RecurrenceDto.fromJson(const {'frequency': 'daily'}).interval, 1);
    });

    test('пустые поля не отправляются', () {
      final json = const RecurrenceDto(frequency: 'daily').toJson();

      expect(json, {'frequency': 'daily', 'interval': 1});
    });

    test('даты года сериализуются объектами', () {
      final json = const RecurrenceDto(
        frequency: 'yearly',
        yearDates: [YearDateDto(month: 3, day: 15)],
      ).toJson();

      expect(json['year_dates'], [
        {'month': 3, 'day': 15},
      ]);
    });
  });

  group('маппер', () {
    test('ответ → модель: сортировка, «последний день», окончание', () {
      final model = const RecurrenceDto(
        frequency: 'monthly',
        monthDays: [-1, 15, 5, 5],
        endDate: '2026-12-31',
      ).toModel(offsetMinutes: 180);

      expect(model.period, RecurrencePeriod.month);
      expect(model.monthDays, [const MonthDay(5), const MonthDay(15), MonthDay.last]);
      expect(model.end, RecurrenceEnd.until(DateTime(2026, 12, 31)));
    });

    test('неизвестный период не роняет разбор', () {
      final model = const RecurrenceDto(frequency: 'hourly').toModel(offsetMinutes: 0);

      expect(model.period, RecurrencePeriod.unknown);
    });

    test('времена из UTC становятся локальными', () {
      final model = const RecurrenceDto(
        frequency: 'daily',
        times: ['05:00', '11:00'],
      ).toModel(offsetMinutes: 180);

      expect(model.times, [const LocalTime(8, 0), const LocalTime(14, 0)]);
    });

    test('модель → запрос: только поля периода, время в UTC, явный end_type', () {
      const model = RecurrenceModel(
        period: RecurrencePeriod.day,
        interval: 2,
        weekDays: [1, 2],
        times: [LocalTime(8, 0), LocalTime(14, 0)],
        end: RecurrenceEnd.afterCount(5),
      );

      final json = model.toDto(offsetMinutes: 180).toJson();

      expect(json, {
        'frequency': 'daily',
        'interval': 2,
        'times': ['05:00', '11:00'],
        'end_type': 'count',
        'end_count': 5,
      });
    });

    test('одно время не отправляется списком', () {
      const model = RecurrenceModel(period: RecurrencePeriod.day, times: [LocalTime(8, 0)]);

      expect(model.toDto(offsetMinutes: 180).times, isNull);
    });

    test('даты окончания и года уходят в формате API', () {
      final model = RecurrenceModel(
        period: RecurrencePeriod.year,
        yearDates: const [YearDate(2, 29)],
        end: RecurrenceEnd.until(DateTime(2030, 1, 5)),
      );

      final dto = model.toDto(offsetMinutes: 0);

      expect(dto.endDate, '2030-01-05');
      expect(dto.endType, 'date');
      expect(dto.yearDates, [const YearDateDto(month: 2, day: 29)]);
    });
  });
}
