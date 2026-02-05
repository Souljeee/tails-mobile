import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/add_pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_dto.dart';

class PetsRemoteDataSource {
  final RestClient _restClient;

  const PetsRemoteDataSource({
    required RestClient restClient,
  }) : _restClient = restClient;

  Future<List<PetDto>> getPets() async {
    final response = await _restClient.get('/pets/');

    if (response == null) {
      throw Exception('Failed to get pets');
    }

    if (response is! List) {
      throw Exception('Failed to get pets: expected JSON list, got ${response.runtimeType}');
    }

    return response
        .map(
          (e) => PetDto.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<void> addPet({
    required AddPetDto dto,
    required String? imagePath,
  }) async {
    final fields = dto.toJson().map((key, value) => MapEntry(key, value.toString()));

    final response = await _restClient.multipart(
      '/pets/',
      fields: fields,
      files: [
        if (imagePath != null)
          RestClientMultipartFile.path(
            field: 'image',
            path: imagePath,
          ),
      ],
    );

    if (response == null) {
      throw Exception('Failed to add pet');
    }
  }
}
