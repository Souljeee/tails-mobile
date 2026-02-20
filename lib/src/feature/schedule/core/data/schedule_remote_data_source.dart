import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/dtos/schedule_event_dto.dart';

class ScheduleRemoteDataSource {
  const ScheduleRemoteDataSource({required this.restClient});

  final RestClient restClient;

  Future<ScheduleEventDtoList> getScheduleEvents({
    required int petId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await restClient.get(
      '/event/period/',
      queryParams: {
        'pet_id': petId.toString(),
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );

    if (response == null || response is! Map<String, dynamic>) {
      throw Exception('Invalid response');
    }

    return response.map(
      (key, value) =>
          MapEntry(DateTime.parse(key), ScheduleEventDto.fromJson(value as Map<String, dynamic>)),
    );
  }
}
