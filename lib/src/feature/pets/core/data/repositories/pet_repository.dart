import 'dart:typed_data';

import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/add_pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/pets_remote_data_source.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/add_pet_model.dart';
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

  Future<void> addPet({
    required AddPetModel model,
    required Uint8List? image,
  }) async {
    await _petsRemoteDataSource.addPet(dto: model.toDto(), image: image);
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


extension on AddPetModel {
  AddPetDto toDto() => AddPetDto(
        name: name,
        petType: petType,
        breed: breed,
        color: color,
        weight: weight,
        gender: gender,
        birthday: birthday,
        castration: castration,
      );
}