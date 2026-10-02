import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/schedule/schedule_bloc.dart';

class _FakeScheduleDataSource implements ScheduleRemoteDataSource {
  bool fail = false;
  int calls = 0;

  @override
  Future<ScheduleEventDtoList> getScheduleEvents({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
  }) async {
    calls++;

    if (fail) {
      throw Exception('schedule is down');
    }

    return {
      startDate: [
        ScheduleEventDto(
          id: 'e1',
          petId: 1,
          title: 'Прогулка',
          type: ScheduleEventTypeEnum.walking,
          done: false,
          date: startDate,
        ),
      ],
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final start = DateTime(2026, 9);
  final end = DateTime(2026, 10);

  late _FakeScheduleDataSource dataSource;
  late ScheduleBloc bloc;
  late List<ScheduleState> states;

  setUp(() {
    dataSource = _FakeScheduleDataSource();
    bloc = ScheduleBloc(
      scheduleRepository: ScheduleRepository(scheduleRemoteDataSource: dataSource),
    );
    states = [];
    bloc.stream.listen(states.add);
  });

  tearDown(() => bloc.close());

  test('обычная загрузка показывает loading, затем данные', () async {
    bloc.add(ScheduleEvent.fetchRequested(startDate: start, endDate: end));
    await pumpEventQueue();

    expect(states.first, isA<ScheduleState$Loading>());
    expect(states.last, isA<ScheduleState$Success>());
  });

  test('тихое обновление не показывает loading и сохраняет данные при ошибке', () async {
    bloc.add(ScheduleEvent.fetchRequested(startDate: start, endDate: end));
    await pumpEventQueue();
    states.clear();

    bloc.add(ScheduleEvent.fetchRequested(startDate: start, endDate: end, silent: true));
    await pumpEventQueue();

    expect(states.whereType<ScheduleState$Loading>(), isEmpty);

    dataSource.fail = true;
    states.clear();

    bloc.add(ScheduleEvent.fetchRequested(startDate: start, endDate: end, silent: true));
    await pumpEventQueue();

    expect(states.whereType<ScheduleState$Error>(), isEmpty);
    expect(bloc.state, isA<ScheduleState$Success>());
  });

  test('тихое обновление без данных ведёт себя как обычная загрузка', () async {
    dataSource.fail = true;

    bloc.add(ScheduleEvent.fetchRequested(startDate: start, endDate: end, silent: true));
    await pumpEventQueue();

    expect(bloc.state, isA<ScheduleState$Error>());
  });

  test('completer завершается после загрузки, в том числе неудачной', () async {
    final ok = Completer<void>();

    bloc.add(ScheduleEvent.fetchRequested(startDate: start, endDate: end, completer: ok));
    await ok.future.timeout(const Duration(seconds: 1));

    dataSource.fail = true;
    final failed = Completer<void>();

    bloc.add(
      ScheduleEvent.fetchRequested(startDate: start, endDate: end, silent: true, completer: failed),
    );
    await failed.future.timeout(const Duration(seconds: 1));

    expect(bloc.state, isA<ScheduleState$Success>());
  });
}
