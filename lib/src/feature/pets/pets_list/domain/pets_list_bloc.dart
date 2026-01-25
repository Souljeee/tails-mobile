import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';

part 'pets_list_event.dart';
part 'pets_list_state.dart';

class PetsListBloc extends Bloc<PetsListEvent, PetsListState> {
  final PetRepository _petRepository;

  PetsListBloc({
    required PetRepository petRepository,
  }) : _petRepository = petRepository, super(const PetsListState.loading()) {
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

      final pets = await _petRepository.getPets();

      emit(PetsListState.success(pets: pets));
    } catch (e, s) {
      addError(e, s);

      emit(const PetsListState.error());
    }
  }
}
