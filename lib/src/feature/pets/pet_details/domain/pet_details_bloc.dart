import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';

part 'pet_details_event.dart';
part 'pet_details_state.dart';

class PetDetailsBloc extends Bloc<PetDetailsEvent, PetDetailsState> {
  final PetRepository _petRepository;

  PetDetailsBloc({
    required PetRepository petRepository,
  })  : _petRepository = petRepository,
        super(const PetDetailsState.loading()) {
    on<PetDetailsEvent>(
      (event, emit) => event.map(
        fetchRequested: (event) => _onFetchRequested(event, emit),
      ),
    );
  }

  Future<void> _onFetchRequested(
    PetDetailsEvent$FetchRequested event,
    Emitter<PetDetailsState> emit,
  ) async {
    try {
      emit(const PetDetailsState.loading());

      final petData = await _petRepository.getPetDetails(id: event.id);

      emit(PetDetailsState.success(petData: petData));
    } catch (e, s) {
      addError(e, s);

      emit(const PetDetailsState.error());
    }
  }
}