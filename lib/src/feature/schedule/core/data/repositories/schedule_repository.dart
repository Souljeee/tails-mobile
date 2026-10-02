import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/create_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/mappers/recurrence_mapper.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/utils/event_time_converter.dart';

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

  /// Ближайшие события питомца, сгруппированные по датам.
  Future<ScheduleEventModelList> getPetUpcomingEvents({
    required int petId,
    required DateTime dateFrom,
    int days = 14,
  }) async {
    final events = await _scheduleRemoteDataSource.getPetUpcomingEvents(
      petId: petId,
      dateFrom: dateFrom,
      days: days,
    );

    return events.map(
      (date, list) => MapEntry(date, list.map((event) => event.toModel()).toList()),
    );
  }

  Future<void> createEvent({required CreateEventModel model}) async {
    await _scheduleRemoteDataSource.createEvent(dto: model.toDto());
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
  /// Время приходит в UTC, в модели — локальное (по `timezone_offset` события).
  ScheduleEventModel toModel() {
    final offset = timeZoneOffset ?? EventTimeConverter.deviceOffsetMinutes(date, time: time);

    return ScheduleEventModel(
      id: id,
      petId: petId,
      title: title,
      description: description,
      time: EventTimeConverter.utcToLocal(time, offsetMinutes: offset),
      timeZoneOffset: timeZoneOffset,
      date: date,
      type: type,
      done: done,
      recurrence: recurrence?.toModel(offsetMinutes: offset),
    );
  }
}

extension on CreateEventModel {
  /// Время из формы — локальное; на сервер уходит UTC и смещение на момент события.
  CreateEventDto toDto() {
    final offset = EventTimeConverter.deviceOffsetMinutes(date, time: time);

    return CreateEventDto(
      title: title,
      description: description,
      time: EventTimeConverter.localToUtc(time, offsetMinutes: offset),
      date: date,
      timezoneOffset: offset,
      petId: petId,
      type: type,
      isRecurring: isRecurring,
      recurrence: recurrence?.toDto(offsetMinutes: offset),
    );
  }
}
