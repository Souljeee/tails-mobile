import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/schedule_event_dto.dart';

class ScheduleRemoteDataSource {
  const ScheduleRemoteDataSource({required this.restClient});

  final RestClient restClient;

  Future<List<ScheduleEventDto>> getScheduleEvents({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
  }) async {
    final response = await restClient.get(
      '/event/period/',
      queryParams: {
        if (petId != null) 'pet_id': petId.toString(),
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );

    if (response == null || response is! List<dynamic>) {
      throw Exception('Invalid response');
    }

    return response.map((value) => ScheduleEventDto.fromJson(value as Map<String, dynamic>)).toList();
  }
}
