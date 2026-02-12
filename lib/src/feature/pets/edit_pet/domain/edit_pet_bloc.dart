import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/edit_pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';

part 'edit_pet_event.dart';
part 'edit_pet_state.dart';

class EditPetBloc extends Bloc<EditPetEvent, EditPetState> {
  final PetRepository _petRepository;

  EditPetBloc({required PetRepository petRepository})
    : _petRepository = petRepository,
      super(const EditPetState.initial()) {
    on<EditPetEvent>(
      (event, emit) => event.map(editingRequested: (event) => _onEditingRequested(event, emit)),
    );
  }

  Future<void> _onEditingRequested(
    EditPetEvent$EditingRequested event,
    Emitter<EditPetState> emit,
  ) async {
    try {
      emit(const EditPetState.loading());

      await _petRepository.editPet(id: event.petId, model: event.pet, image: event.image);

      emit(const EditPetState.success());
    } catch (e, s) {
      addError(e, s);

      emit(const EditPetState.error());
    }finally {
      emit(const EditPetState.initial());
    }
  }
}
