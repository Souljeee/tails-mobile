import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';

part 'delete_pet_event.dart';
part 'delete_pet_state.dart';

class DeletePetBloc extends Bloc<DeletePetEvent, DeletePetState> {
  final PetRepository _petRepository;

  DeletePetBloc({
    required PetRepository petRepository,
  })  : _petRepository = petRepository,
        super(const DeletePetState.initial()) {
    on<DeletePetEvent>(
      (event, emit) => event.map(
        deleteRequested: (event) => _onDeleteRequested(event, emit),
      ),
    );
  }

  Future<void> _onDeleteRequested(
    DeletePetEvent$DeleteRequested event,
    Emitter<DeletePetState> emit,
  ) async {
    try {
      emit(const DeletePetState.loading());

      await _petRepository.deletePet(id: event.id);

      emit(const DeletePetState.success());
    } catch (e, s) {
      addError(e, s);

      emit(const DeletePetState.error());
    }finally {
      emit(const DeletePetState.initial());
    }
  }
}