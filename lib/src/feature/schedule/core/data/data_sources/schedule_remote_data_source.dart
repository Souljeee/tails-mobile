import 'package:intl/intl.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/create_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/series_stats_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';

class ScheduleRemoteDataSource {
  const ScheduleRemoteDataSource({required this.restClient});

  final RestClient restClient;

  Future<ScheduleEventDtoList> getScheduleEvents({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
  }) async {
    final response = await restClient.get(
      '/event_schedule/period/',
      queryParams: {
        if (petId != null) 'pet_id': petId.toString(),
        'date_from': DateFormat('yyyy-MM-dd').format(startDate),
        'date_to': DateFormat('yyyy-MM-dd').format(endDate),
      },
    );

    return _parseEventsByDate(response);
  }

  /// Ближайшие события питомца: `GET /pets/{id}/upcoming/`.
  Future<ScheduleEventDtoList> getPetUpcomingEvents({
    required int petId,
    required DateTime dateFrom,
    int days = 14,
  }) async {
    final response = await restClient.get(
      '/pets/$petId/upcoming/',
      queryParams: {
        'days': days.toString(),
        'date_from': DateFormat('yyyy-MM-dd').format(dateFrom),
      },
    );

    return _parseEventsByDate(response);
  }

  ScheduleEventDtoList _parseEventsByDate(Object? response) {
    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Invalid response');
    }

    return Map<DateTime, List<ScheduleEventDto>>.fromEntries(
      response.entries.map(
        (MapEntry<String, dynamic> entry) => MapEntry(
          DateTime.parse(entry.key),
          (entry.value as List<dynamic>)
              .map((value) => ScheduleEventDto.fromJson(value as Map<String, dynamic>))
              .toList(),
        ),
      ),
    );
  }

  Future<void> createEvent({required CreateEventDto dto}) async {
    await restClient.post('/event_schedule/', body: dto.toJson());
  }

  /// [time] — время вхождения в UTC (`HH:mm`); сервер требует его, когда у события несколько
  /// времён в день, и игнорирует в остальных случаях.
  Future<void> markEventAsDone({
    required String eventId,
    required DateTime date,
    String? time,
  }) async {
    await restClient.post(
      '/event_schedule/$eventId/mark_done/',
      body: {'date': DateFormat('yyyy-MM-dd').format(date), if (time != null) 'time': time},
    );
  }

  /// [time] — время вхождения в UTC (`HH:mm`); сервер требует его, когда у события несколько
  /// времён в день, и игнорирует в остальных случаях.
  Future<void> markEventAsUndone({
    required String eventId,
    required DateTime date,
    String? time,
  }) async {
    await restClient.post(
      '/event_schedule/$eventId/mark_undone/',
      body: {'date': DateFormat('yyyy-MM-dd').format(date), if (time != null) 'time': time},
    );
  }

  /// Отмена вхождения ([OccurrenceScope.one]) либо даты и всех следующих ([OccurrenceScope.future]).
  /// [time] — время слота в UTC (`HH:mm`), нужно при нескольких временах в день.
  Future<ScheduleEventDto> cancelOccurrence({
    required String eventId,
    required DateTime date,
    required OccurrenceScope scope,
    String? time,
  }) async {
    final response = await restClient.post(
      '/event_schedule/$eventId/cancel/',
      body: _occurrenceBody(date, time, scope: scope),
    );

    return _parseEvent(response);
  }

  /// Возврат отменённого вхождения (серию, остановленную отменой «и все следующие», не удлиняет).
  Future<ScheduleEventDto> restoreOccurrence({
    required String eventId,
    required DateTime date,
    String? time,
  }) async {
    final response = await restClient.post(
      '/event_schedule/$eventId/restore/',
      body: _occurrenceBody(date, time),
    );

    return _parseEvent(response);
  }

  /// Сколько вхождений осталось и прошло относительно [date] (для подтверждения отмены серии).
  Future<SeriesStatsDto> getSeriesStats({required String eventId, required DateTime date}) async {
    final response = await restClient.get(
      '/event_schedule/$eventId/series_stats/',
      queryParams: {'date': DateFormat('yyyy-MM-dd').format(date)},
    );
    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid response');
    }

    return SeriesStatsDto.fromJson(response);
  }

  /// Изменение вхождения. [event] — поля как на сервере: для [OccurrenceScope.one] только
  /// `title`, `description`, `type`, `time` (UTC), для [OccurrenceScope.future] — форма события
  /// как при создании. Ответ: `event` и, если серия разделилась, `created_event`.
  Future<({ScheduleEventDto event, ScheduleEventDto? createdEvent})> editOccurrence({
    required String eventId,
    required DateTime date,
    required OccurrenceScope scope,
    required Map<String, dynamic> event,
    String? time,
  }) async {
    final response = await restClient.post(
      '/event_schedule/$eventId/edit/',
      body: {
        ..._occurrenceBody(date, time, scope: scope),
        'event': event,
      },
    );
    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid response');
    }
    final created = response['created_event'];

    return (
      event: _parseEvent(response['event']),
      createdEvent: created == null ? null : _parseEvent(created),
    );
  }

  Map<String, dynamic> _occurrenceBody(DateTime date, String? time, {OccurrenceScope? scope}) => {
    'date': DateFormat('yyyy-MM-dd').format(date),
    if (time != null) 'time': time,
    if (scope != null) 'scope': scope.apiValue,
  };

  ScheduleEventDto _parseEvent(Object? response) {
    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid response');
    }

    return ScheduleEventDto.fromJson(response);
  }
}
