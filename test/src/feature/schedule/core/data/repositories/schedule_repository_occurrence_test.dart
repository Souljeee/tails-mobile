import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/series_stats_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/schedule_remote_data_source.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_occurrence_ref.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_status.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/series_stats.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';

ScheduleEventDto _dto({
  String id = 'e1',
  bool cancelled = false,
  DateTime? doneAt,
  List<int>? reminders,
}) => ScheduleEventDto(
  id: id,
  petId: 1,
  title: 'Таблетки',
  type: ScheduleEventTypeEnum.dailyPills,
  done: doneAt != null,
  cancelled: cancelled,
  doneAt: doneAt,
  date: DateTime(2026, 10, 8),
  time: '05:00:00',
  timeZoneOffset: 180,
  reminders: reminders,
);

class _FakeDataSource implements ScheduleRemoteDataSource {
  final calls = <String>[];
  String? lastTime;
  OccurrenceScope? lastScope;
  Map<String, dynamic>? lastEvent;
  ScheduleEventDto? createdEvent;

  @override
  Future<ScheduleEventDto> cancelOccurrence({
    required String eventId,
    required DateTime date,
    required OccurrenceScope scope,
    String? time,
  }) async {
    calls.add('cancel:$eventId');
    lastTime = time;
    lastScope = scope;

    return _dto(cancelled: true);
  }

  @override
  Future<ScheduleEventDto> restoreOccurrence({
    required String eventId,
    required DateTime date,
    String? time,
  }) async {
    calls.add('restore:$eventId');
    lastTime = time;

    return _dto();
  }

  @override
  Future<SeriesStatsDto> getSeriesStats({required String eventId, required DateTime date}) async =>
      SeriesStatsDto(
        remaining: 7,
        past: 3,
        seriesEnd: DateTime.utc(2026, 10, 14),
        isOpenEnded: false,
        cancelledDates: [DateTime.utc(2026, 10, 9)],
      );

  @override
  Future<({ScheduleEventDto event, ScheduleEventDto? createdEvent})> editOccurrence({
    required String eventId,
    required DateTime date,
    required OccurrenceScope scope,
    required Map<String, dynamic> event,
    String? time,
  }) async {
    lastTime = time;
    lastScope = scope;
    lastEvent = event;

    return (event: _dto(reminders: event['reminders'] as List<int>?), createdEvent: createdEvent);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeDataSource dataSource;
  late ScheduleRepository repository;
  final ref = EventOccurrenceRef(
    eventId: 'e1',
    date: DateTime(2026, 10, 8, 13, 45),
    time: '08:00',
    timeZoneOffset: 180,
  );

  setUp(() {
    dataSource = _FakeDataSource();
    repository = ScheduleRepository(scheduleRemoteDataSource: dataSource);
  });

  group('EventOccurrenceRef', () {
    test('дата без времени суток, смещение в равенстве не участвует', () {
      final other = EventOccurrenceRef(
        eventId: 'e1',
        date: DateTime(2026, 10, 8),
        time: '08:00',
        timeZoneOffset: 0,
      );

      expect(ref.date, DateTime(2026, 10, 8));
      expect(ref, other);
      expect(ref, isNot(EventOccurrenceRef(eventId: 'e1', date: ref.date, time: '09:00')));
    });
  });

  group('статус и поля вхождения', () {
    test('отмена главнее отметки', () {
      ScheduleEventModel model({bool done = false, bool cancelled = false}) => ScheduleEventModel(
        id: 'e1',
        petId: 1,
        title: 'T',
        type: ScheduleEventTypeEnum.custom,
        done: done,
        cancelled: cancelled,
        date: DateTime(2026, 10, 8),
      );

      expect(model().status, ScheduleEventStatus.scheduled);
      expect(model(done: true).status, ScheduleEventStatus.done);
      expect(model(cancelled: true).status, ScheduleEventStatus.cancelled);
      expect(model(done: true, cancelled: true).status, ScheduleEventStatus.cancelled);
    });

    test('старый ответ без cancelled и done_at разбирается', () {
      final dto = ScheduleEventDto.fromJson(const {
        'id': 'e1',
        'pet': 1,
        'title': 'T',
        'type': 'walking',
        'done': false,
        'start_date': '2026-10-08',
      });

      expect(dto.cancelled, isFalse);
      expect(dto.doneAt, isNull);
    });

    test('done_at из ответа — в модели локальное время', () {
      final dto = ScheduleEventDto.fromJson(const {
        'id': 'e1',
        'pet': 1,
        'title': 'T',
        'type': 'walking',
        'done': true,
        'cancelled': true,
        'done_at': '2026-10-08T06:12:00Z',
        'start_date': '2026-10-08',
      });

      expect(dto.cancelled, isTrue);
      expect(dto.doneAt, DateTime.utc(2026, 10, 8, 6, 12));
    });
  });

  group('репозиторий', () {
    test('отмена: время вхождения уходит в UTC, scope передаётся, ответ — модель', () async {
      final result = await repository.cancelOccurrence(ref, scope: OccurrenceScope.future);

      expect(dataSource.lastTime, '05:00');
      expect(dataSource.lastScope, OccurrenceScope.future);
      expect(result.cancelled, isTrue);
      expect(result.time, '08:00');
    });

    test('возврат: время вхождения уходит в UTC', () async {
      final result = await repository.restoreOccurrence(ref);

      expect(dataSource.calls, ['restore:e1']);
      expect(dataSource.lastTime, '05:00');
      expect(result.cancelled, isFalse);
    });

    test('вхождение без времени уходит без time', () async {
      await repository.restoreOccurrence(EventOccurrenceRef(eventId: 'e1', date: ref.date));

      expect(dataSource.lastTime, isNull);
    });

    test('series_stats: даты без времени суток', () async {
      final stats = await repository.getSeriesStats(ref);

      expect(stats.remaining, 7);
      expect(stats.past, 3);
      expect(stats.seriesEnd, DateTime(2026, 10, 14));
      expect(stats.cancelledDates, [DateTime(2026, 10, 9)]);
      expect(stats.isLastOccurrence, isFalse);
    });

    test('правка одной даты: только переданные поля, время в UTC', () async {
      final result = await repository.editOccurrenceFields(
        ref,
        title: 'Другое',
        time: '09:30',
        type: ScheduleEventTypeEnum.custom,
      );

      expect(dataSource.lastScope, OccurrenceScope.one);
      expect(dataSource.lastEvent, {'title': 'Другое', 'type': 'custom', 'time': '06:30'});
      expect(dataSource.lastTime, '05:00');
      expect(result.isSplit, isFalse);
    });

    test('«и все следующие»: форма целиком, время и смещение как при создании', () async {
      dataSource.createdEvent = _dto(id: 'e2');
      final date = DateTime(2026, 10, 8);

      final result = await repository.editOccurrenceAndFollowing(
        ref,
        CreateEventModel(
          title: 'Новое',
          description: null,
          time: '10:00',
          date: date,
          petId: 1,
          type: ScheduleEventTypeEnum.custom,
          isRecurring: false,
        ),
      );

      expect(dataSource.lastScope, OccurrenceScope.future);
      expect(dataSource.lastEvent?['title'], 'Новое');
      expect(dataSource.lastEvent?['start_date'], '2026-10-08');
      expect(dataSource.lastEvent?['is_recurring'], false);
      expect(result.isSplit, isTrue);
      expect(result.createdEvent?.id, 'e2');
    });
  });

  test('SeriesStats: последнее событие серии и бессрочная серия', () {
    SeriesStats stats(int? remaining) => SeriesStats(
      remaining: remaining,
      past: 0,
      seriesEnd: null,
      isOpenEnded: remaining == null,
      cancelledDates: const [],
    );

    expect(stats(1).isLastOccurrence, isTrue);
    expect(stats(0).isLastOccurrence, isTrue);
    expect(stats(2).isLastOccurrence, isFalse);
    expect(stats(null).isLastOccurrence, isFalse);
  });

  group('напоминание', () {
    test('только эта дата: напоминание уходит списком', () async {
      final result = await repository.editOccurrenceFields(
        ref,
        reminder: const CopyWithWrapper.value(EventReminder.before(30)),
      );

      expect(dataSource.lastEvent, {
        'reminders': [30],
      });
      expect(result.event.reminder, const EventReminder.before(30));
    });

    test('«не напоминать» уходит пустым списком, сброс — null', () async {
      await repository.editOccurrenceFields(
        ref,
        reminder: const CopyWithWrapper.value(EventReminder.none()),
      );
      expect(dataSource.lastEvent, {'reminders': <int>[]});

      await repository.editOccurrenceFields(
        ref,
        reminder: const CopyWithWrapper<EventReminder?>.value(null),
      );
      expect(dataSource.lastEvent, {'reminders': null});
    });

    test('без reminder поле не отправляется', () async {
      await repository.editOccurrenceFields(ref, title: 'Новое');

      expect(dataSource.lastEvent, {'title': 'Новое'});
    });

    test('эта дата и следующие: напоминание формы уходит в запрос', () async {
      await repository.editOccurrenceAndFollowing(
        ref,
        CreateEventModel(
          title: 'T',
          description: null,
          time: '08:00',
          date: DateTime(2026, 10, 8),
          petId: 1,
          type: ScheduleEventTypeEnum.custom,
          isRecurring: false,
          reminder: const EventReminder.before(1440),
        ),
      );

      expect(dataSource.lastEvent?['reminders'], [1440]);
    });
  });
}
