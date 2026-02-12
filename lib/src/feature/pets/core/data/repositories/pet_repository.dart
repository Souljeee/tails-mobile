import 'dart:async';
import 'dart:io';

import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/add_pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/breed_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/edit_pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_details_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/pets_remote_data_source.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/add_pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/edit_pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pets_repository_events.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

class PetRepository {
  final PetsRemoteDataSource _petsRemoteDataSource;

  final _eventStreamController = StreamController<PetsRepositoryEventsEvent>.broadcast();

  Stream<PetsRepositoryEventsEvent> get eventStream => _eventStreamController.stream;

  PetRepository({required PetsRemoteDataSource petsRemoteDataSource})
    : _petsRemoteDataSource = petsRemoteDataSource;

  Future<List<PetModel>> getPets() async {
    final pets = await _petsRemoteDataSource.getPets();

    return pets.map((pet) => pet.toModel()).toList();
  }

  Future<PetDetailsModel> getPetDetails({required int id}) async {
    final petDetails = await _petsRemoteDataSource.getPetDetails(id: id);

    return petDetails.toModel();
  }

  Future<void> addPet({required AddPetModel model, required File? image}) async {
    await _petsRemoteDataSource.addPet(dto: model.toDto(), imagePath: image?.path);

    _eventStreamController.add(const PetsRepositoryEventsEvent.petsAdded());
  }

  Future<List<BreedModel>> getBreeds({required PetTypeEnum petType}) async {
    final breeds = await _petsRemoteDataSource.getBreeds(petType: petType);

    return breeds.map((breed) => breed.toModel()).toList();
  }

  Future<void> editPet({required int id, required EditPetModel model, required File? image}) async {
    await _petsRemoteDataSource.editPet(id: id, dto: model.toDto(), imagePath: image?.path);

    _eventStreamController.add(const PetsRepositoryEventsEvent.petEdited());
  }

  Future<void> deletePet({required int id}) async {
    await _petsRemoteDataSource.deletePet(id: id);

    _eventStreamController.add(const PetsRepositoryEventsEvent.petDeleted());
  }
}

extension on PetDto {
  PetModel toModel() => PetModel(
    id: id,
    petType: petType,
    name: name,
    breed: breed.toModel(),
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
    breedId: breedId,
    color: color,
    weight: weight,
    gender: gender,
    birthday: birthday,
    hasCastration: hasCastration,
  );
}

extension on BreedDto {
  BreedModel toModel() => BreedModel(id: id, name: name);
}

extension on PetDetailsDto {
  PetDetailsModel toModel() => PetDetailsModel(
    id: id,
    petType: petType,
    name: name,
    breed: breed.toModel(),
    gender: gender,
    birthday: birthday,
    color: color,
    image: image,
    weight: weight,
    createdAt: createdAt,
    updatedAt: updatedAt,
    hasCastration: hasCastration,
  );
}


extension on EditPetModel {
  EditPetDto toDto() => EditPetDto(
    name: name,
    petType: petType,
    breedId: breedId,
    color: color,
    weight: weight,
    gender: gender,
    birthday: birthday,
    hasCastration: hasCastration,
  );
}