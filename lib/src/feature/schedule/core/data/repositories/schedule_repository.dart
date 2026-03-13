import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';

class ScheduleRepository {
  final ScheduleRemoteDataSource _scheduleRemoteDataSource;

  const ScheduleRepository({required ScheduleRemoteDataSource scheduleRemoteDataSource})
    : _scheduleRemoteDataSource = scheduleRemoteDataSource;

  Future<ScheduleEventModelList> getScheduleEvents({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
  }) async {
    final events = await _scheduleRemoteDataSource.getScheduleEvents(
      startDate: startDate,
      endDate: endDate,
      petId: petId,
    );

    final eventEntries = events.entries.map(
      (entry) => MapEntry(entry.key, entry.value.map((event) => event.toModel()).toList()),
    );

    return Map<DateTime, List<ScheduleEventModel>>.fromEntries(eventEntries);
  }

  Future<void> updateEventDoneStatus({
    required bool value,
    required String eventId,
    required DateTime date,
  }) async {
    if (value) {
      await _scheduleRemoteDataSource.markEventAsDone(eventId: eventId, date: date);
    } else {
      await _scheduleRemoteDataSource.markEventAsUndone(eventId: eventId, date: date);
    }
  }
}

extension on ScheduleEventDto {
  ScheduleEventModel toModel() => ScheduleEventModel(
    id: id,
    petId: petId,
    title: title,
    description: description,
    time: time,
    timeZoneOffset: timeZoneOffset,
    date: date,
    type: type,
    done: done,
    recurrence: recurrence?.toModel(),
  );
}

extension on RecurrenceDto {
  RecurrenceModel toModel() => RecurrenceModel(
    frequency: frequency,
    interval: interval,
    weekDays: weekDays,
    monthDays: monthDays,
    endDate: endDate,
    endCount: endCount,
    endType: endType,
  );
}
