import 'package:intl/intl.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/create_event_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';

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
}
