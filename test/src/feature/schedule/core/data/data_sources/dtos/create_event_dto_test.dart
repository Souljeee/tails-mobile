import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/create_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

void main() {
  test('serializes create event according to the API contract', () {
    final dto = CreateEventDto(
      title: 'Ветеринар',
      description: 'Плановый приём',
      time: '10:39',
      timezoneOffset: 180,
      date: DateTime(2026, 9, 26),
      petId: 11,
      type: ScheduleEventTypeEnum.custom,
      isRecurring: false,
    );

    expect(dto.toJson(), {
      'title': 'Ветеринар',
      'description': 'Плановый приём',
      'time': '10:39',
      'timezone_offset': 180,
      'start_date': '2026-09-26',
      'pet': 11,
      'type': 'custom',
      'is_recurring': false,
      'recurrence': null,
    });
  });

  test('serializes blank time as null', () {
    final dto = CreateEventDto(
      title: 'Ветеринар',
      description: null,
      time: '  ',
      timezoneOffset: 180,
      date: DateTime(2026, 9, 26),
      petId: 11,
      type: ScheduleEventTypeEnum.custom,
      isRecurring: false,
    );

    expect(dto.toJson()['time'], isNull);
  });
}
