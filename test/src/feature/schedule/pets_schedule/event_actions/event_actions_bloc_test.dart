import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/event_actions_bloc.dart';

import '../../../../../helpers/recording_analytics_sink.dart';

class _FakeDataSource implements ScheduleRemoteDataSource {
  final calls = <String>[];
  bool fail = false;
  Completer<void>? gate;

  ScheduleEventDto _dto(String id, {required bool cancelled}) => ScheduleEventDto(
    id: id,
    petId: 1,
    title: 'Таблетки',
    type: ScheduleEventTypeEnum.dailyPills,
    done: false,
    cancelled: cancelled,
    date: DateTime(2026, 10, 8),
  );

  @override
  Future<ScheduleEventDto> cancelOccurrence({
    required String eventId,
    required DateTime date,
    required OccurrenceScope scope,
    String? time,
  }) async {
    calls.add('cancel:$eventId:${scope.apiValue}');
    await gate?.future;
    if (fail) {
      throw Exception('down');
    }

    return _dto(eventId, cancelled: true);
  }

  @override
  Future<ScheduleEventDto> restoreOccurrence({
    required String eventId,
    required DateTime date,
    String? time,
  }) async {
    calls.add('restore:$eventId');
    if (fail) {
      throw Exception('down');
    }

    return _dto(eventId, cancelled: false);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ScheduleEventModel _occurrence(String id, {bool recurring = true}) => ScheduleEventModel(
  id: id,
  petId: 1,
  title: 'Таблетки',
  type: ScheduleEventTypeEnum.dailyPills,
  done: false,
  date: DateTime(2026, 10, 8),
  recurrence: recurring ? const RecurrenceModel(period: RecurrencePeriod.day) : null,
);

void main() {
  const delay = Duration(milliseconds: 40);

  late _FakeDataSource dataSource;
  late EventActionsBloc bloc;
  late List<EventActionsState> states;
  late RecordingAnalyticsSink analytics;

  Iterable<EventActionEffect> effects() =>
      states.map((s) => s.effect).whereType<EventActionEffect>();

  setUp(() {
    analytics = RecordingAnalyticsSink();
    TailsAnalytics.configure(sinks: [analytics]);
    addTearDown(TailsAnalytics.reset);

    dataSource = _FakeDataSource();
    bloc = EventActionsBloc(
      scheduleRepository: ScheduleRepository(scheduleRemoteDataSource: dataSource),
      undoDelay: delay,
    );
    states = [];
    bloc.stream.listen(states.add);
  });

  tearDown(() => bloc.close());

  test('отмена применяется сразу, а запрос уходит только после паузы', () async {
    bloc.add(
      EventActionsEvent.cancelRequested(occurrence: _occurrence('e1'), scope: OccurrenceScope.one),
    );
    await pumpEventQueue();

    expect(effects().single, isA<EventActionEffect$CancelApplied>());
    expect(bloc.state.pending, isNotNull);
    expect(dataSource.calls, isEmpty);

    await Future<void>.delayed(delay * 3);

    expect(dataSource.calls, ['cancel:e1:one']);
    expect(effects().last, isA<EventActionEffect$CancelCommitted>());
    expect(bloc.state.pending, isNull);
    expect(analytics.names, ['event_cancelled']);
    expect(analytics.events.single.parameters, {
      'scope': 'one',
      'event_type': 'daily_pills',
      'is_recurring': true,
    });
  });

  test('«Вернуть» гасит таймер: запрос не уходит, список откатывается', () async {
    bloc
      ..add(
        EventActionsEvent.cancelRequested(
          occurrence: _occurrence('e1'),
          scope: OccurrenceScope.future,
        ),
      )
      ..add(const EventActionsEvent.undoRequested());
    await Future<void>.delayed(delay * 3);

    expect(dataSource.calls, isEmpty);
    expect(effects().last, isA<EventActionEffect$CancelUndone>());
    expect((effects().last as EventActionEffect$CancelUndone).scope, OccurrenceScope.future);
    expect(bloc.state.pending, isNull);
    expect(analytics.names, ['event_cancel_undone']);
  });

  test('flush отправляет отмену немедленно', () async {
    bloc
      ..add(
        EventActionsEvent.cancelRequested(
          occurrence: _occurrence('e1'),
          scope: OccurrenceScope.one,
        ),
      )
      ..add(const EventActionsEvent.flushRequested());
    await pumpEventQueue();

    expect(dataSource.calls, ['cancel:e1:one']);
    expect(effects().last, isA<EventActionEffect$CancelCommitted>());
  });

  test('flush без ожидающей отмены ничего не делает', () async {
    bloc.add(const EventActionsEvent.flushRequested());
    await pumpEventQueue();

    expect(dataSource.calls, isEmpty);
    expect(states, isEmpty);
  });

  test('вторая отмена сразу отправляет первую', () async {
    bloc
      ..add(
        EventActionsEvent.cancelRequested(
          occurrence: _occurrence('e1'),
          scope: OccurrenceScope.one,
        ),
      )
      ..add(
        EventActionsEvent.cancelRequested(
          occurrence: _occurrence('e2'),
          scope: OccurrenceScope.one,
        ),
      );
    await pumpEventQueue();

    expect(dataSource.calls, ['cancel:e1:one']);
    expect(bloc.state.pending?.occurrence.id, 'e2');

    await Future<void>.delayed(delay * 3);

    expect(dataSource.calls, ['cancel:e1:one', 'cancel:e2:one']);
  });

  test('ошибка сервера откатывает состояние и не оставляет ожидающей отмены', () async {
    dataSource.fail = true;
    final errors = <Object>[];
    await runZonedGuarded(() async {
      bloc
        ..add(
          EventActionsEvent.cancelRequested(
            occurrence: _occurrence('e1'),
            scope: OccurrenceScope.one,
          ),
        )
        ..add(const EventActionsEvent.flushRequested());
      await pumpEventQueue();
    }, (e, s) => errors.add(e));

    expect(effects().last, isA<EventActionEffect$CancelFailed>());
    expect(bloc.state.pending, isNull);
    expect(analytics.names, isEmpty);
  });

  test('повтор после ошибки снова проходит по общему пути', () async {
    dataSource.fail = true;
    await runZonedGuarded(() async {
      bloc
        ..add(
          EventActionsEvent.cancelRequested(
            occurrence: _occurrence('e1'),
            scope: OccurrenceScope.one,
          ),
        )
        ..add(const EventActionsEvent.flushRequested());
      await pumpEventQueue();
    }, (e, s) {});

    dataSource.fail = false;
    bloc
      ..add(
        EventActionsEvent.cancelRequested(
          occurrence: _occurrence('e1'),
          scope: OccurrenceScope.one,
        ),
      )
      ..add(const EventActionsEvent.flushRequested());
    await pumpEventQueue();

    expect(effects().last, isA<EventActionEffect$CancelCommitted>());
  });

  test('закрытие блока отправляет ожидающую отмену', () async {
    bloc.add(
      EventActionsEvent.cancelRequested(
        occurrence: _occurrence('e1'),
        scope: OccurrenceScope.future,
      ),
    );
    await pumpEventQueue();

    await bloc.close();
    await pumpEventQueue();

    expect(dataSource.calls, ['cancel:e1:future']);
  });

  test('закрытие блока во время отправки не дублирует запрос', () async {
    dataSource.gate = Completer<void>();
    bloc
      ..add(
        EventActionsEvent.cancelRequested(
          occurrence: _occurrence('e1'),
          scope: OccurrenceScope.one,
        ),
      )
      ..add(const EventActionsEvent.flushRequested());
    await pumpEventQueue();

    final closing = bloc.close();
    dataSource.gate!.complete();
    await closing;
    await pumpEventQueue();

    expect(dataSource.calls, ['cancel:e1:one']);
  });

  test('возврат отменённого одиночного события: применяется сразу, затем подтверждается', () async {
    bloc.add(
      EventActionsEvent.restoreRequested(
        occurrence: _occurrence('e1', recurring: false).copyWithCancelled(),
      ),
    );
    await pumpEventQueue();

    expect(effects().map((e) => e.runtimeType), [
      EventActionEffect$RestoreApplied,
      EventActionEffect$RestoreCommitted,
    ]);
    expect(dataSource.calls, ['restore:e1']);
    expect(analytics.names, ['event_restored']);
  });

  test('ошибка возврата откатывает вхождение в отменённое', () async {
    dataSource.fail = true;
    await runZonedGuarded(() async {
      bloc.add(
        EventActionsEvent.restoreRequested(
          occurrence: _occurrence('e1', recurring: false).copyWithCancelled(),
        ),
      );
      await pumpEventQueue();
    }, (e, s) {});

    expect(effects().last, isA<EventActionEffect$RestoreFailed>());
  });

  test('возврат вхождения с ожидающей отменой равен «Вернуть»', () async {
    final occurrence = _occurrence('e1');
    bloc
      ..add(EventActionsEvent.cancelRequested(occurrence: occurrence, scope: OccurrenceScope.one))
      ..add(EventActionsEvent.restoreRequested(occurrence: occurrence));
    await Future<void>.delayed(delay * 3);

    expect(dataSource.calls, isEmpty);
    expect(effects().last, isA<EventActionEffect$CancelUndone>());
  });

  test('одинаковые эффекты подряд различаются идентификатором', () async {
    final occurrence = _occurrence('e1');
    bloc
      ..add(EventActionsEvent.cancelRequested(occurrence: occurrence, scope: OccurrenceScope.one))
      ..add(const EventActionsEvent.undoRequested())
      ..add(EventActionsEvent.cancelRequested(occurrence: occurrence, scope: OccurrenceScope.one))
      ..add(const EventActionsEvent.undoRequested());
    await pumpEventQueue();

    final ids = effects().map((e) => e.id).toList();
    expect(ids.toSet().length, ids.length);
  });
}

extension on ScheduleEventModel {
  ScheduleEventModel copyWithCancelled() => ScheduleEventModel(
    id: id,
    petId: petId,
    title: title,
    type: type,
    done: false,
    date: date,
    recurrence: recurrence,
    cancelled: true,
  );
}
