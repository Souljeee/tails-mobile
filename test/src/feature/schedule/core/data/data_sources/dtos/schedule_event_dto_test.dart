import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

Map<String, dynamic> _json(String type) => {
  'id': 'e1',
  'pet': 1,
  'title': 'Приём',
  'type': type,
  'done': false,
  'start_date': '2026-10-10',
};

void main() {
  test('разбирает тип vetVisit', () {
    final dto = ScheduleEventDto.fromJson(_json('vetVisit'));

    expect(dto.type, ScheduleEventTypeEnum.vetVisit);
  });

  test('неизвестный тип с сервера не ломает разбор и становится custom', () {
    final dto = ScheduleEventDto.fromJson(_json('somethingNew'));

    expect(dto.type, ScheduleEventTypeEnum.custom);
  });
}
