import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/pets/pets_overview/domain/next_event_selector.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';

ScheduleEventModel _event(
  String id, {
  required int petId,
  required DateTime date,
  String? time,
  bool done = false,
}) => ScheduleEventModel(
  id: id,
  petId: petId,
  title: 'event $id',
  type: ScheduleEventTypeEnum.custom,
  done: done,
  date: date,
  time: time,
);

void main() {
  final today = DateTime(2026, 9, 29);
  final tomorrow = DateTime(2026, 9, 30);
  final now = DateTime(2026, 9, 29, 12, 30);

  test('пропускает прошедшие сегодня и выполненные события', () {
    final result = selectNextEvents({
      today: [
        _event('past', petId: 1, date: today, time: '08:00:00'),
        _event('done', petId: 1, date: today, time: '18:00:00', done: true),
        _event('next', petId: 1, date: today, time: '17:05:00'),
      ],
    }, now: now);

    expect(result[1]?.event.id, 'next');
    expect(result[1]?.date, today);
  });

  test('событие «на весь день» идёт раньше событий со временем', () {
    final result = selectNextEvents({
      today: [
        _event('timed', petId: 1, date: today, time: '13:00:00'),
        _event('allday', petId: 1, date: today),
      ],
    }, now: now);

    expect(result[1]?.event.id, 'allday');
  });

  test('если сегодня ничего не осталось, берёт событие следующего дня', () {
    final result = selectNextEvents({
      today: [_event('past', petId: 1, date: today, time: '08:00:00')],
      tomorrow: [_event('later', petId: 1, date: tomorrow, time: '07:00:00')],
    }, now: now);

    expect(result[1]?.event.id, 'later');
    expect(result[1]?.date, tomorrow);
  });

  test('считает события каждого питомца отдельно и игнорирует прошлые дни', () {
    final result = selectNextEvents({
      DateTime(2026, 9, 20): [_event('old', petId: 1, date: DateTime(2026, 9, 20))],
      today: [
        _event('a', petId: 1, date: today, time: '20:00:00'),
        _event('b', petId: 2, date: today, time: '14:00:00'),
      ],
    }, now: now);

    expect(result[1]?.event.id, 'a');
    expect(result[2]?.event.id, 'b');
    expect(result.length, 2);
  });

  test('питомцев без подходящих событий в результате нет', () {
    final result = selectNextEvents({
      today: [_event('done', petId: 3, date: today, done: true)],
    }, now: now);

    expect(result, isEmpty);
  });
}
