import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_occurrence_ref.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/schedule/schedule_bloc.dart';

/// Серия `series` на три дня и одиночное событие `single` на первый день.
class _FakeDataSource implements ScheduleRemoteDataSource {
  int fetches = 0;
  int? lastPetId;
  DateTime? lastStart;

  ScheduleEventDto _dto(String id, int day) => ScheduleEventDto(
    id: id,
    petId: 1,
    title: id,
    type: ScheduleEventTypeEnum.walking,
    done: false,
    date: DateTime(2026, 10, day),
  );

  @override
  Future<ScheduleEventDtoList> getScheduleEvents({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
  }) async {
    fetches++;
    lastPetId = petId;
    lastStart = startDate;

    return {
      DateTime(2026, 10): [_dto('series', 1), _dto('single', 1)],
      DateTime(2026, 10, 2): [_dto('series', 2)],
      DateTime(2026, 10, 3): [_dto('series', 3)],
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final start = DateTime(2026, 9);
  final end = DateTime(2026, 11);

  late _FakeDataSource dataSource;
  late ScheduleBloc bloc;

  setUp(() async {
    dataSource = _FakeDataSource();
    bloc = ScheduleBloc(
      scheduleRepository: ScheduleRepository(scheduleRemoteDataSource: dataSource),
    )..add(ScheduleEvent.fetchRequested(startDate: start, endDate: end, petId: 7));
    await pumpEventQueue();
  });

  tearDown(() => bloc.close());

  Map<DateTime, List<dynamic>> days() => (bloc.state as ScheduleState$Success).scheduleEvents;

  bool cancelled(String id, int day) => (bloc.state as ScheduleState$Success)
      .scheduleEvents[DateTime(2026, 10, day)]!
      .firstWhere((e) => e.id == id)
      .cancelled;

  EventOccurrenceRef ref(String id, int day) =>
      EventOccurrenceRef(eventId: id, date: DateTime(2026, 10, day));

  test('отмена одного вхождения не трогает соседей', () async {
    bloc.add(ScheduleEvent.occurrenceCancelledChanged(ref: ref('series', 2), cancelled: true));
    await pumpEventQueue();

    expect(cancelled('series', 2), isTrue);
    expect(cancelled('series', 1), isFalse);
    expect(cancelled('series', 3), isFalse);
    expect(cancelled('single', 1), isFalse);
    expect(dataSource.fetches, 1);
  });

  test('«и все следующие» убирает вхождения серии после даты и оставляет саму дату', () async {
    bloc.add(
      ScheduleEvent.occurrenceCancelledChanged(
        ref: ref('series', 2),
        cancelled: true,
        dropFollowing: true,
      ),
    );
    await pumpEventQueue();

    expect(days()[DateTime(2026, 10, 3)], isEmpty);
    expect(cancelled('series', 2), isTrue);
    expect(days()[DateTime(2026, 10)], hasLength(2));
  });

  test('возврат снимает отмену', () async {
    bloc.add(ScheduleEvent.occurrenceCancelledChanged(ref: ref('series', 2), cancelled: true));
    bloc.add(ScheduleEvent.occurrenceCancelledChanged(ref: ref('series', 2), cancelled: false));
    await pumpEventQueue();

    expect(cancelled('series', 2), isFalse);
  });

  test('вхождение заменяется моделью с сервера', () async {
    final current =
        (bloc.state as ScheduleState$Success).scheduleEvents[DateTime(2026, 10, 2)]!.single;

    bloc.add(
      ScheduleEvent.occurrenceReplaced(
        occurrence: current.copyWith(
          title: const CopyWithWrapper.value('Новое'),
          cancelled: const CopyWithWrapper.value(true),
        ),
      ),
    );
    await pumpEventQueue();

    final replaced =
        (bloc.state as ScheduleState$Success).scheduleEvents[DateTime(2026, 10, 2)]!.single;
    expect(replaced.title, 'Новое');
    expect(replaced.cancelled, isTrue);
  });

  test('refreshRequested перезагружает последнее окно тихо', () async {
    final states = <ScheduleState>[];
    bloc.stream.listen(states.add);

    final completer = Completer<void>();
    bloc.add(ScheduleEvent.refreshRequested(completer: completer));
    await completer.future.timeout(const Duration(seconds: 1));

    expect(dataSource.fetches, 2);
    expect(dataSource.lastPetId, 7);
    expect(dataSource.lastStart, start);
    expect(states.whereType<ScheduleState$Loading>(), isEmpty);
  });

  test('refreshRequested без прежней загрузки ничего не делает', () async {
    final fresh = ScheduleBloc(
      scheduleRepository: ScheduleRepository(scheduleRemoteDataSource: dataSource),
    );
    addTearDown(fresh.close);

    final completer = Completer<void>();
    fresh.add(ScheduleEvent.refreshRequested(completer: completer));
    await completer.future.timeout(const Duration(seconds: 1));

    expect(dataSource.fetches, 1);
    expect(fresh.state, isA<ScheduleState$Loading>());
  });
}
