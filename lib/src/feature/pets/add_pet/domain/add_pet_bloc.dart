import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/add_pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

part 'add_pet_event.dart';
part 'add_pet_state.dart';

class AddPetBloc extends Bloc<AddPetEvent, AddPetState> {
  final PetRepository _petRepository;
  AddPetBloc({
    required PetRepository petRepository,
  }) : _petRepository = petRepository, super(const AddPetState.initial()) {
    on<AddPetEvent>(
      (event, emit) => event.map(
        addingRequested: (event) => _onAddingRequested(event, emit),
      ),
    );
  }

  Future<void> _onAddingRequested(
    AddPetEvent$AddingRequested event,
    Emitter<AddPetState> emit,
  ) async {
    try {
      emit(const AddPetState.loading());

      await _petRepository.addPet(
        model: AddPetModel(
          name: event.name,
          petType: event.petType,
          breed: event.breed,
          color: event.color,
          weight: event.weight,
          sex: event.sex,
          birthDate: event.birthDate,
          castration: event.castration,
        ),
        image: event.image,
      );

      emit(const AddPetState.success());
    } catch (e, s) {
      addError(e, s);

      emit(const AddPetState.error());
    }finally{
      emit(const AddPetState.initial());
    }
  }
}