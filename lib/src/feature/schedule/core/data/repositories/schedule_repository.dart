import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/create_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/series_stats_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/mappers/recurrence_mapper.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/edit_occurrence_result.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_occurrence_ref.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/series_stats.dart';
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
    String? time,
    int? timeZoneOffset,
  }) async {
    // Отметка идёт на конкретное вхождение: время из модели — локальное, серверу нужен UTC.
    final offset = timeZoneOffset ?? EventTimeConverter.deviceOffsetMinutes(date, time: time);
    final wireTime = EventTimeConverter.localToUtc(time, offsetMinutes: offset);

    if (value) {
      await _scheduleRemoteDataSource.markEventAsDone(eventId: eventId, date: date, time: wireTime);
    } else {
      await _scheduleRemoteDataSource.markEventAsUndone(
        eventId: eventId,
        date: date,
        time: wireTime,
      );
    }
  }

  /// Отменяет вхождение ([OccurrenceScope.one]) либо его и все следующие ([OccurrenceScope.future]).
  Future<ScheduleEventModel> cancelOccurrence(
    EventOccurrenceRef ref, {
    required OccurrenceScope scope,
  }) async {
    final dto = await _scheduleRemoteDataSource.cancelOccurrence(
      eventId: ref.eventId,
      date: ref.date,
      scope: scope,
      time: _wireTime(ref),
    );

    return dto.toModel();
  }

  /// Возвращает отменённое вхождение.
  Future<ScheduleEventModel> restoreOccurrence(EventOccurrenceRef ref) async {
    final dto = await _scheduleRemoteDataSource.restoreOccurrence(
      eventId: ref.eventId,
      date: ref.date,
      time: _wireTime(ref),
    );

    return dto.toModel();
  }

  Future<SeriesStats> getSeriesStats(EventOccurrenceRef ref) async {
    final dto = await _scheduleRemoteDataSource.getSeriesStats(
      eventId: ref.eventId,
      date: ref.date,
    );

    return dto.toModel();
  }

  /// «Изменить только эту дату»: меняются только переданные поля (`time` — локальное).
  Future<EditOccurrenceResult> editOccurrenceFields(
    EventOccurrenceRef ref, {
    String? title,
    String? description,
    ScheduleEventTypeEnum? type,
    String? time,
    CopyWithWrapper<EventReminder?>? reminder,
  }) async {
    final offset = _offsetOf(ref);
    final fields = <String, dynamic>{
      'title': ?title,
      'description': ?description,
      'type': ?type?.name,
      if (time != null) 'time': EventTimeConverter.localToUtc(time, offsetMinutes: offset),
      // `null` в запросе сбрасывает напоминание вхождения до напоминания серии.
      if (reminder != null) 'reminders': reminder.value?.toWire(),
    };

    return _edit(ref, OccurrenceScope.one, fields);
  }

  /// «Изменить эту дату и все следующие»: [model] — форма целиком (как при создании); у серии
  /// с окончанием «после N повторений» N уже должен быть остатком с этой даты.
  Future<EditOccurrenceResult> editOccurrenceAndFollowing(
    EventOccurrenceRef ref,
    CreateEventModel model,
  ) => _edit(ref, OccurrenceScope.future, model.toDto().toJson());

  Future<EditOccurrenceResult> _edit(
    EventOccurrenceRef ref,
    OccurrenceScope scope,
    Map<String, dynamic> fields,
  ) async {
    final result = await _scheduleRemoteDataSource.editOccurrence(
      eventId: ref.eventId,
      date: ref.date,
      scope: scope,
      event: fields,
      time: _wireTime(ref),
    );

    return EditOccurrenceResult(
      event: result.event.toModel(),
      createdEvent: result.createdEvent?.toModel(),
    );
  }

  int _offsetOf(EventOccurrenceRef ref) =>
      ref.timeZoneOffset ?? EventTimeConverter.deviceOffsetMinutes(ref.date, time: ref.time);

  /// Время вхождения в UTC для запроса: в модели оно локальное.
  String? _wireTime(EventOccurrenceRef ref) =>
      EventTimeConverter.localToUtc(ref.time, offsetMinutes: _offsetOf(ref));
}

extension on SeriesStatsDto {
  SeriesStats toModel() => SeriesStats(
    remaining: remaining,
    past: past,
    seriesEnd: seriesEnd == null
        ? null
        : DateTime(seriesEnd!.year, seriesEnd!.month, seriesEnd!.day),
    isOpenEnded: isOpenEnded,
    cancelledDates: [for (final d in cancelledDates) DateTime(d.year, d.month, d.day)],
  );
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
      cancelled: cancelled,
      doneAt: doneAt?.toLocal(),
      recurrence: recurrence?.toModel(offsetMinutes: offset),
      reminder: EventReminder.fromWire(reminders),
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
      reminders: reminder?.toWire(),
    );
  }
}
