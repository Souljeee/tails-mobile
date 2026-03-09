import 'package:intl/intl.dart';
import 'package:rest_client/rest_client.dart';
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

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Invalid response');
    }

    final responseMap = response;
    
    final events = Map<DateTime, List<ScheduleEventDto>>.fromEntries(
      responseMap.entries.map((MapEntry<String, dynamic> entry) => MapEntry(
            DateTime.parse(entry.key),
            (entry.value as List<dynamic>)
                .map((value) => ScheduleEventDto.fromJson(value as Map<String, dynamic>))
                .toList(),
          )),
    );

    return events;
  }
}
