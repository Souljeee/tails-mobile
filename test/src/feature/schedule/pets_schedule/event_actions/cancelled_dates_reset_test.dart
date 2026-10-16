import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/cancelled_dates_reset.dart';

void main() {
  final start = DateTime(2026, 10, 5);
  final cancelled = [DateTime(2026, 10, 7), DateTime(2026, 10, 9), DateTime(2026, 10, 12)];

  test('без отмен сбрасывать нечего', () {
    expect(
      CancelledDatesReset.willReset(
        cancelledDates: const [],
        start: start,
        rule: const RecurrenceModel(period: RecurrencePeriod.day),
      ),
      isFalse,
    );
  });

  test('«каждый день» сохраняет все отмены', () {
    expect(
      CancelledDatesReset.lost(
        cancelledDates: cancelled,
        start: start,
        rule: const RecurrenceModel(period: RecurrencePeriod.day),
      ),
      isEmpty,
    );
  });

  test('«через день» с понедельника: нечётные дни остаются, чётные теряются', () {
    expect(
      CancelledDatesReset.lost(
        cancelledDates: cancelled,
        start: start,
        rule: const RecurrenceModel(period: RecurrencePeriod.day, interval: 2),
      ),
      [DateTime(2026, 10, 12)],
    );
  });

  test('по будням сохраняет будни, сброс только выходных', () {
    expect(
      CancelledDatesReset.lost(
        cancelledDates: [DateTime(2026, 10, 10), DateTime(2026, 10, 12)],
        start: start,
        rule: const RecurrenceModel(period: RecurrencePeriod.week, weekDays: [1, 2, 3, 4, 5]),
      ),
      [DateTime(2026, 10, 10)],
    );
  });

  test('перенос начала вперёд срезает более ранние отмены', () {
    expect(
      CancelledDatesReset.lost(
        cancelledDates: cancelled,
        start: DateTime(2026, 10, 8),
        rule: const RecurrenceModel(period: RecurrencePeriod.day),
      ),
      [DateTime(2026, 10, 7)],
    );
  });

  test('окончание серии срезает отмены после него', () {
    expect(
      CancelledDatesReset.lost(
        cancelledDates: cancelled,
        start: start,
        rule: RecurrenceModel(
          period: RecurrencePeriod.day,
          end: RecurrenceEnd.until(DateTime(2026, 10, 9)),
        ),
      ),
      [DateTime(2026, 10, 12)],
    );
  });

  test('повторение отключено: остаётся только дата события', () {
    expect(
      CancelledDatesReset.lost(cancelledDates: cancelled, start: DateTime(2026, 10, 9), rule: null),
      [DateTime(2026, 10, 7), DateTime(2026, 10, 12)],
    );
  });

  test('время суток в датах не мешает', () {
    expect(
      CancelledDatesReset.lost(
        cancelledDates: [DateTime(2026, 10, 7, 13, 30)],
        start: start,
        rule: const RecurrenceModel(period: RecurrencePeriod.day),
      ),
      isEmpty,
    );
  });
}
