import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/schedule/edit_event/domain/edit_changes.dart';
import 'package:tails_mobile/src/feature/schedule/edit_event/domain/edit_event_bloc.dart';

import '../../../../helpers/recording_analytics_sink.dart';

class _FakeDataSource implements ScheduleRemoteDataSource {
  OccurrenceScope? scope;
  Map<String, dynamic>? sent;
  bool fail = false;

  @override
  Future<({ScheduleEventDto event, ScheduleEventDto? createdEvent})> editOccurrence({
    required String eventId,
    required DateTime date,
    required OccurrenceScope scope,
    required Map<String, dynamic> event,
    String? time,
  }) async {
    if (fail) {
      throw Exception('down');
    }
    this.scope = scope;
    sent = event;

    return (
      event: ScheduleEventDto(
        id: eventId,
        petId: 1,
        title: 'Новое',
        type: ScheduleEventTypeEnum.dailyPills,
        done: false,
        date: date,
      ),
      createdEvent: null,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeDataSource dataSource;
  late EditEventBloc bloc;
  late RecordingAnalyticsSink analytics;

  final occurrence = ScheduleEventModel(
    id: 'e1',
    petId: 1,
    title: 'Таблетки',
    type: ScheduleEventTypeEnum.dailyPills,
    done: false,
    date: DateTime(2026, 10, 20),
    time: '17:05:00',
  );
  final model = CreateEventModel(
    title: 'Новое',
    description: null,
    time: null,
    date: DateTime(2026, 10, 20),
    petId: 1,
    type: ScheduleEventTypeEnum.dailyPills,
    isRecurring: false,
  );

  setUp(() {
    analytics = RecordingAnalyticsSink();
    TailsAnalytics.configure(sinks: [analytics]);
    addTearDown(TailsAnalytics.reset);

    dataSource = _FakeDataSource();
    bloc = EditEventBloc(
      scheduleRepository: ScheduleRepository(scheduleRemoteDataSource: dataSource),
    );
  });

  tearDown(() => bloc.close());

  test('«только эта дата» отправляет лишь изменённые поля', () async {
    final states = <EditEventState>[];
    bloc.stream.listen(states.add);

    bloc.add(
      EditEventEvent.saveRequested(
        occurrence: occurrence,
        scope: OccurrenceScope.one,
        model: model,
        changes: const EditChanges({EditedField.title}),
      ),
    );
    await pumpEventQueue();

    expect(dataSource.scope, OccurrenceScope.one);
    expect(dataSource.sent, {'title': 'Новое'});
    expect(states.first, isA<EditEventState$Loading>());
    expect(states.last, isA<EditEventState$Success>());
    expect(analytics.events.single.name, 'event_edited');
  });

  test('«только эта дата»: напоминание уходит и попадает в аналитику видом', () async {
    final withReminder = CreateEventModel(
      title: 'Новое',
      description: null,
      time: '10:00',
      date: DateTime(2026, 10, 20),
      petId: 1,
      type: ScheduleEventTypeEnum.dailyPills,
      isRecurring: false,
      reminder: const EventReminder.before(45),
    );

    bloc.add(
      EditEventEvent.saveRequested(
        occurrence: occurrence,
        scope: OccurrenceScope.one,
        model: withReminder,
        changes: const EditChanges({EditedField.reminder}),
      ),
    );
    await pumpEventQueue();

    expect(dataSource.sent, {
      'reminders': [45],
    });
    expect(analytics.events.single.parameters['reminder'], 'custom');
  });

  test('«и все следующие» отправляет всю форму', () async {
    bloc.add(
      EditEventEvent.saveRequested(
        occurrence: occurrence,
        scope: OccurrenceScope.future,
        model: model,
        changes: const EditChanges({EditedField.title, EditedField.date}),
      ),
    );
    await pumpEventQueue();

    expect(dataSource.scope, OccurrenceScope.future);
    expect(dataSource.sent!['title'], 'Новое');
    expect(dataSource.sent!.containsKey('pet'), isTrue);
  });

  test('ошибка сети даёт состояние error и не пишет аналитику', () async {
    dataSource.fail = true;
    final errors = <Object>[];
    final states = <EditEventState>[];
    bloc.stream.listen(states.add);

    await runZonedGuarded(() async {
      bloc.add(
        EditEventEvent.saveRequested(
          occurrence: occurrence,
          scope: OccurrenceScope.one,
          model: model,
          changes: const EditChanges({EditedField.title}),
        ),
      );
      await pumpEventQueue();
    }, (e, _) => errors.add(e));

    expect(states.last, isA<EditEventState$Error>());
    expect(analytics.events, isEmpty);
  });
}
