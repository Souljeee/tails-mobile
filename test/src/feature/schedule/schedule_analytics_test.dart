import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/create_event_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/mark_done/mark_done_bloc.dart';

import '../../../helpers/recording_analytics_sink.dart';

final class _FakeScheduleRepository extends Fake implements ScheduleRepository {
  Exception? error;

  @override
  Future<void> createEvent({required CreateEventModel model}) async {
    if (error != null) throw error!;
  }

  @override
  Future<void> updateEventDoneStatus({
    required bool value,
    required String eventId,
    required DateTime date,
    String? time,
    int? timeZoneOffset,
  }) async {
    if (error != null) throw error!;
  }
}

CreateEventModel _model({RecurrenceModel? recurrence, String? time, String? description}) =>
    CreateEventModel(
      title: 'Прививка Барсику',
      description: description,
      time: time,
      date: DateTime(2026, 10, 6),
      petId: 1,
      type: ScheduleEventTypeEnum.vetVisit,
      isRecurring: recurrence != null,
      recurrence: recurrence,
    );

Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  late RecordingAnalyticsSink sink;
  late _FakeScheduleRepository repository;

  setUp(() {
    sink = RecordingAnalyticsSink();
    TailsAnalytics.configure(sinks: [sink]);
    repository = _FakeScheduleRepository();
  });

  tearDown(TailsAnalytics.reset);

  group('CreateEventBloc', () {
    test('простое событие: тип в snake_case, без названия и описания', () async {
      final bloc = CreateEventBloc(scheduleRepository: repository);
      addTearDown(bloc.close);

      bloc.add(
        CreateEventEvent.createRequested(
          model: _model(time: '10:00', description: 'x'),
        ),
      );
      await _pump();

      expect(sink.events.single.name, 'event_created');
      expect(sink.events.single.parameters, {
        'event_type': 'vet_visit',
        'has_time': true,
        'has_description': true,
        'is_recurring': false,
      });
      expect('${sink.events.single}', isNot(contains('Барсик')));
    });

    test('повторяющееся событие: период, интервал, окончание, времена в день', () async {
      final bloc = CreateEventBloc(scheduleRepository: repository);
      addTearDown(bloc.close);

      bloc.add(
        CreateEventEvent.createRequested(
          model: _model(
            recurrence: const RecurrenceModel(
              period: RecurrencePeriod.day,
              interval: 2,
              times: [LocalTime(8, 0), LocalTime(20, 0)],
              end: RecurrenceEnd.afterCount(5),
            ),
          ),
        ),
      );
      await _pump();

      expect(sink.events.single.parameters, {
        'event_type': 'vet_visit',
        'has_time': false,
        'has_description': false,
        'is_recurring': true,
        'recurrence_period': 'day',
        'recurrence_interval': 2,
        'recurrence_end': 'count',
        'times_per_day': 2,
      });
      expect(sink.properties[TailsAnalyticsUserProperty.hasRecurringEvents], true);
    });

    test('ошибка: event_create_failed', () async {
      repository.error = Exception('x');
      final bloc = CreateEventBloc(scheduleRepository: repository);
      addTearDown(bloc.close);

      bloc.add(CreateEventEvent.createRequested(model: _model()));
      await _pump();

      expect(sink.names, ['event_create_failed']);
    });
  });

  group('MarkDoneBloc', () {
    MarkDoneEvent request({required bool value}) => MarkDoneEvent.markDoneRequested(
      eventId: '1',
      date: DateTime(2026, 10, 6),
      value: value,
      analyticsEventType: 'feeding',
      analyticsIsRecurring: true,
      analyticsFrom: 'pet_details',
    );

    test('выполнено и отмена', () async {
      final bloc = MarkDoneBloc(scheduleRepository: repository);
      addTearDown(bloc.close);

      bloc.add(request(value: true));
      await _pump();
      bloc.add(request(value: false));
      await _pump();

      expect(sink.names, ['event_marked_done', 'event_marked_undone']);
      expect(sink.events[0].parameters, {
        'event_type': 'feeding',
        'is_recurring': true,
        'from': 'pet_details',
      });
      expect(sink.events[1].parameters, {'event_type': 'feeding'});
    });

    test('ошибка не отправляет событие', () async {
      repository.error = Exception('x');
      final bloc = MarkDoneBloc(scheduleRepository: repository);
      addTearDown(bloc.close);

      bloc.add(request(value: true));
      await _pump();

      expect(sink.events, isEmpty);
    });
  });
}
