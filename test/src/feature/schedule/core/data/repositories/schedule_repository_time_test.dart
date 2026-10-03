import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/create_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/utils/event_time_converter.dart';

class _FakeDataSource implements ScheduleRemoteDataSource {
  CreateEventDto? created;
  final marks = <({bool done, String? time})>[];
  ScheduleEventDtoList response = {};

  @override
  Future<void> createEvent({required CreateEventDto dto}) async => created = dto;

  @override
  Future<ScheduleEventDtoList> getScheduleEvents({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
  }) async => response;

  @override
  Future<ScheduleEventDtoList> getPetUpcomingEvents({
    required int petId,
    required DateTime dateFrom,
    int days = 14,
  }) async => response;

  @override
  Future<void> markEventAsDone({
    required String eventId,
    required DateTime date,
    String? time,
  }) async => marks.add((done: true, time: time));

  @override
  Future<void> markEventAsUndone({
    required String eventId,
    required DateTime date,
    String? time,
  }) async => marks.add((done: false, time: time));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeDataSource dataSource;
  late ScheduleRepository repository;

  setUp(() {
    dataSource = _FakeDataSource();
    repository = ScheduleRepository(scheduleRemoteDataSource: dataSource);
  });

  test('создание: локальное время уходит в UTC вместе со смещением устройства', () async {
    final date = DateTime(2026, 10, 5);
    final offset = EventTimeConverter.deviceOffsetMinutes(date, time: '17:05');

    await repository.createEvent(
      model: CreateEventModel(
        title: 'Таблетка',
        description: null,
        time: '17:05',
        date: date,
        petId: 1,
        type: ScheduleEventTypeEnum.custom,
        isRecurring: false,
      ),
    );

    expect(dataSource.created?.timezoneOffset, offset);
    expect(dataSource.created?.time, EventTimeConverter.localToUtc('17:05', offsetMinutes: offset));
  });

  test('создание без времени остаётся без времени', () async {
    await repository.createEvent(
      model: CreateEventModel(
        title: 'Весь день',
        description: null,
        time: null,
        date: DateTime(2026, 10, 5),
        petId: 1,
        type: ScheduleEventTypeEnum.custom,
        isRecurring: false,
      ),
    );

    expect(dataSource.created?.time, isNull);
  });

  test('чтение: UTC из ответа переводится в локальное по timezone_offset события', () async {
    final day = DateTime(2026, 10, 5);
    dataSource.response = {
      day: [
        ScheduleEventDto(
          id: 'e1',
          petId: 1,
          title: 'Прогулка',
          type: ScheduleEventTypeEnum.walking,
          done: false,
          date: day,
          time: '14:05:00',
          timeZoneOffset: 180,
        ),
      ],
    };

    final result = await repository.getScheduleEvents(startDate: day, endDate: day);

    expect(result[day]!.single.time, '17:05');
  });

  test('ключ смещения в ответе — timezone_offset', () {
    final dto = ScheduleEventDto.fromJson(const {
      'id': 'e1',
      'pet': 1,
      'title': 'Прогулка',
      'type': 'walking',
      'done': false,
      'start_date': '2026-10-05',
      'time': '14:05:00',
      'timezone_offset': 180,
    });

    expect(dto.timeZoneOffset, 180);
  });

  test('отметка выполнения: время вхождения уходит в UTC по смещению события', () async {
    final date = DateTime(2026, 10, 5);

    await repository.updateEventDoneStatus(
      value: true,
      eventId: 'e1',
      date: date,
      time: '08:00',
      timeZoneOffset: 180,
    );
    await repository.updateEventDoneStatus(
      value: false,
      eventId: 'e1',
      date: date,
      time: '21:30',
      timeZoneOffset: 180,
    );
    await repository.updateEventDoneStatus(value: true, eventId: 'e1', date: date);

    expect(dataSource.marks, [
      (done: true, time: '05:00'),
      (done: false, time: '18:30'),
      (done: true, time: null),
    ]);
  });
}
