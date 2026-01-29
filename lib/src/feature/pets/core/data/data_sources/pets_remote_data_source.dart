import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_dto.dart';

class PetsRemoteDataSource {
  final RestClient _restClient;

  const PetsRemoteDataSource({
    required RestClient restClient,
  }) : _restClient = restClient;

  Future<List<PetDto>> getPets() async {
    final response = await _restClient.get('/pets');

    if (response == null) {
      throw Exception('Failed to get pets');
    }

    return (response as List<Map<String, dynamic>>)
        .map(PetDto.fromJson)
        .toList();
  }
}
