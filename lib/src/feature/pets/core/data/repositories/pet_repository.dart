import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/pets_remote_data_source.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';

class PetRepository {
  final PetsRemoteDataSource _petsRemoteDataSource;

  const PetRepository({
    required PetsRemoteDataSource petsRemoteDataSource,
  }) : _petsRemoteDataSource = petsRemoteDataSource;

  Future<List<PetModel>> getPets() async {
    final pets = await _petsRemoteDataSource.getPets();
    
    return pets.map((pet) => pet.toModel()).toList();
  }
}

extension on PetDto {
  PetModel toModel() => PetModel(
    id: id,
    petType: petType,
    name: name,
    breed: breed,
    gender: gender,
    birthday: birthday,
    color: color,
    image: image,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
