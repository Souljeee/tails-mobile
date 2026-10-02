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
    final dto = ScheduleEventDto.fromJson({
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
}
