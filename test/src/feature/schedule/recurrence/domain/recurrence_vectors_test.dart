import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_calculator.dart';

/// Общие с бэкендом тестовые векторы (`tracker/tests/data/recurrence_vectors.json`).
/// Файл копируется между репозиториями без изменений; семантику меняют сначала в нём.
const _supportedVersion = 2;

DateTime _date(String value) => DateTime.parse(value);

String _iso(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

RecurrenceModel _rule(Map<String, dynamic> json) {
  final period = RecurrencePeriod.fromApi(json['frequency'] as String);
  final endDate = json['end_date'] as String?;
  final endCount = json['end_count'] as int?;

  return RecurrenceModel(
    period: period,
    interval: (json['interval'] as int?) ?? 1,
    weekDays: ((json['week_days'] as List?) ?? const []).cast<int>().toSet().toList()..sort(),
    monthDays:
        (((json['month_days'] as List?) ?? const []).cast<int>().map(MonthDay.new).toSet().toList()
          ..sort()),
    yearDates:
        (((json['year_dates'] as List?) ?? const [])
            .map((e) => YearDate((e as Map)['month'] as int, e['day'] as int))
            .toSet()
            .toList()
          ..sort()),
    end: endDate != null
        ? RecurrenceEnd.until(_date(endDate))
        : endCount != null
        ? RecurrenceEnd.afterCount(endCount)
        : const RecurrenceEnd.never(),
  );
}

void main() {
  final file = File('test/src/feature/schedule/recurrence/data/recurrence_vectors.json');
  final vectors = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  test('версия файла векторов поддерживается', () {
    expect(vectors['version'], _supportedVersion);
  });

  for (final raw in vectors['cases'] as List) {
    final testCase = raw as Map<String, dynamic>;

    test('${testCase['id']}: ${testCase['description']}', () {
      final start = _date(testCase['start_date'] as String);
      final ruleJson = testCase['rule'] as Map<String, dynamic>;
      final rule = _rule(ruleJson);
      final expected = testCase['expect'] as Map<String, dynamic>;

      final error = RecurrenceCalculator.endError(rule, start);
      if (expected.containsKey('error')) {
        final expectedError = expected['error'] as Map<String, dynamic>;
        expect(error, isNotNull, reason: 'ожидалась ошибка ${expectedError['code']}');
        if (expectedError['code'] == 'end_before_start') {
          expect(error, isA<RecurrenceEndError$BeforeStart>());
        } else {
          expect(error, isA<RecurrenceEndError$BeforeFirst>());
          expect(_iso((error! as RecurrenceEndError$BeforeFirst).first), expectedError['first']);
        }

        return;
      }
      expect(error, isNull);

      final until = RecurrenceCalculator.until(rule, start);
      expect(until == null ? null : _iso(until), expected['until']);
      expect(_iso(RecurrenceCalculator.firstOccurrence(rule, start)!), expected['first']);

      final window = (testCase['window'] as List).cast<String>();
      final from = _date(window[0]);
      final dates = RecurrenceCalculator.occurrencesInWindow(
        rule,
        start,
        from: from.isBefore(start) ? start : from,
        to: _date(window[1]),
        until: until,
      );
      expect(dates.map(_iso).toList(), expected['dates']);

      if (expected.containsKey('slots')) {
        final times = ((ruleJson['times'] as List).cast<String>().toSet().toList()..sort());
        final slots = [
          for (final day in dates)
            for (final time in times) [_iso(day), time],
        ];
        expect(slots, expected['slots']);
      }
    });
  }
}
