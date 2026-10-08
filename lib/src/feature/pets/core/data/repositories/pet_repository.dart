import 'dart:async';
import 'dart:io';

import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/add_pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/breed_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/edit_pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_details_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/pets_remote_data_source.dart';
import 'package:tails_mobile/src/feature/pets/core/data/pet_color_store.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/add_pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/edit_pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pets_repository_events.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

class PetRepository {
  final PetsRemoteDataSource _petsRemoteDataSource;
  final PetColorStore? _petColorStore;

  final _eventStreamController = StreamController<PetsRepositoryEventsEvent>.broadcast();

  Stream<PetsRepositoryEventsEvent> get eventStream => _eventStreamController.stream;

  int? _knownPetsCount;

  /// Сколько питомцев было известно после последней загрузки списка или изменения.
  ///
  /// Нужно только аналитике (`is_first_pet`, `pets_count`); `null`, пока список не загружали.
  int? get knownPetsCount => _knownPetsCount;

  PetRepository({required PetsRemoteDataSource petsRemoteDataSource, PetColorStore? petColorStore})
    : _petsRemoteDataSource = petsRemoteDataSource,
      _petColorStore = petColorStore;

  Future<List<PetModel>> getPets() async {
    final pets = await _petsRemoteDataSource.getPets();

    final colors = await _petColorStore?.sync(pets.map((pet) => pet.id));

    _reportPetsProperties(pets);

    return pets.map((pet) => pet.toModel(colorIndex: colors?[pet.id] ?? 0)).toList();
  }

  Future<PetDetailsModel> getPetDetails({required int id}) async {
    final petDetails = await _petsRemoteDataSource.getPetDetails(id: id);

    final colorIndex = await _petColorStore?.colorIndexFor(petDetails.id) ?? 0;

    return petDetails.toModel(colorIndex: colorIndex);
  }

  Future<void> addPet({required AddPetModel model, required File? image}) async {
    await _petsRemoteDataSource.addPet(dto: model.toDto(), imagePath: image?.path);

    _changeKnownCount(1);
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

    _changeKnownCount(-1);
    _eventStreamController.add(const PetsRepositoryEventsEvent.petDeleted());
  }

  void _changeKnownCount(int delta) {
    final known = _knownPetsCount;
    if (known == null) return;

    _knownPetsCount = (known + delta).clamp(0, 1 << 20);
    TailsAnalytics.setUserProperty(TailsAnalyticsUserProperty.petsCount, _knownPetsCount!);
  }

  /// Обновляет свойства пользователя в аналитике по свежему списку питомцев.
  void _reportPetsProperties(List<PetDto> pets) {
    _knownPetsCount = pets.length;

    TailsAnalytics.setUserProperty(TailsAnalyticsUserProperty.petsCount, pets.length);
    TailsAnalytics.setUserProperty(
      TailsAnalyticsUserProperty.dogsCount,
      pets.where((pet) => pet.petType == PetTypeEnum.dog).length,
    );
    TailsAnalytics.setUserProperty(
      TailsAnalyticsUserProperty.catsCount,
      pets.where((pet) => pet.petType == PetTypeEnum.cat).length,
    );
  }
}

extension on PetDto {
  PetModel toModel({int colorIndex = 0}) => PetModel(
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
    colorIndex: colorIndex,
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
  PetDetailsModel toModel({int colorIndex = 0}) => PetDetailsModel(
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
    colorIndex: colorIndex,
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
