import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

part 'pets_list_event.dart';
part 'pets_list_state.dart';

class PetsListBloc extends Bloc<PetsListEvent, PetsListState> {
  final PetRepository _petRepository;

  PetsListBloc({
    required PetRepository petRepository,
  })  : _petRepository = petRepository,
        super(const PetsListState.loading()) {
    on<PetsListEvent>(
      (event, emit) => event.map(
        fetchRequested: (event) => _onFetchRequested(event, emit),
      ),
    );
  }

  Future<void> _onFetchRequested(
    PetsListEvent$FetchRequested event,
    Emitter<PetsListState> emit,
  ) async {
    try {
      emit(const PetsListState.loading());

      //final pets = await _petRepository.getPets();

      await Future.delayed(const Duration(seconds: 2));

      emit(PetsListState.success(pets: _mockedPets));

      //emit(PetsListState.success(pets: pets));
    } catch (e, s) {
      addError(e, s);

      emit(const PetsListState.error());
    }
  }
}

final _mockedPets = [
  PetModel(
    id: '1',
    name: 'Rex',
    image: 'https://storage-api.petstory.ru/resize/1000x1000x80/cb/48/7f/cb487f4677a640329e92ac0076004607.jpeg',
    petType: PetTypeEnum.dog,
    birthday: DateTime.now().subtract(Duration(days: 365)),
    breed: 'Labrador',
    gender: 'Male',
    color: 'Black',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  PetModel(
    id: '2',
    name: 'Bella',
    image: 'https://domkohouse.com.ua/content/uploads/images/dizayn-bez-nazvanija-19.png',
    petType: PetTypeEnum.cat,
    birthday: DateTime.now().subtract(Duration(days: 1000)),
    breed: 'Siamese',
    gender: 'Female',
    color: 'White',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  PetModel(
    id: '3',
    name: 'Charlie',
    image: 'https://habrastorage.org/getpro/habr//post_images/c35/2fe/a96/c352fea96714a16c6f5656841d50e1e5.jpg',
    petType: PetTypeEnum.cat,
    birthday: DateTime.now().subtract(Duration(days: 1500)),
    breed: 'Siamese',
    gender: 'Male',
    color: 'White',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];
