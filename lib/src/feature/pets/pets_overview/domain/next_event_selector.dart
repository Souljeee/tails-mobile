import 'package:tails_mobile/src/feature/pets/pets_overview/domain/models/pets_overview.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';

/// Выбирает для каждого питомца ближайшее невыполненное событие.
///
/// Сегодня учитываются события «на весь день» и те, время которых ещё не прошло.
/// События следующих дней берутся целиком. Внутри дня «на весь день» идут первыми.
/// Возвращает карту `petId -> событие`; питомцев без подходящих событий в ней нет.
Map<int, PetNextEvent> selectNextEvents(ScheduleEventModelList events, {required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  final nowMinutes = now.hour * 60 + now.minute;
  final result = <int, PetNextEvent>{};

  final days = events.keys.where((day) => !day.isBefore(today)).toList()..sort();

  for (final day in days) {
    final dayEvents = List<ScheduleEventModel>.of(events[day] ?? [])
      ..sort((a, b) => _minutesOf(a).compareTo(_minutesOf(b)));

    for (final event in dayEvents) {
      if (event.done || result.containsKey(event.petId)) {
        continue;
      }

      final isToday = day == today;
      final isPassed = event.time != null && _minutesOf(event) < nowMinutes;

      if (isToday && isPassed) {
        continue;
      }

      result[event.petId] = PetNextEvent(event: event, date: day);
    }
  }

  return result;
}

/// Минуты от начала дня; событие без времени («весь день») считается самым ранним.
int _minutesOf(ScheduleEventModel event) {
  final time = event.time;

  if (time == null || time.length < 5) {
    return -1;
  }

  final hours = int.tryParse(time.substring(0, 2)) ?? 0;
  final minutes = int.tryParse(time.substring(3, 5)) ?? 0;

  return hours * 60 + minutes;
}
