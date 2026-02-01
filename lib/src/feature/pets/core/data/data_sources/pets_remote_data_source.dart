import 'dart:typed_data';

import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/add_pet_dto.dart';
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

    return (response as List<Map<String, dynamic>>).map(PetDto.fromJson).toList();
  }

  Future<void> addPet({
    required AddPetDto dto,
    required Uint8List? image,
  }) async {
    final response = await _restClient.multipart(
      '/pets',
      fields: dto.toJson().map((key, value) => MapEntry(key, value.toString())),
      files: [
        if (image != null)
          RestClientMultipartFile.bytes(
            field: 'image',
            bytes: image,
            filename: '',
          ),
      ],
    );

    if (response == null) {
      throw Exception('Failed to add pet');
    }
  }
}
