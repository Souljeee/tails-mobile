import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pets_repository_events.dart';

part 'pet_details_event.dart';
part 'pet_details_state.dart';

class PetDetailsBloc extends Bloc<PetDetailsEvent, PetDetailsState> {
  final PetRepository _petRepository;
  final int _petId;

  late final StreamSubscription<PetsRepositoryEventsEvent> _petDetailsSubscription;

  PetDetailsBloc({
    required PetRepository petRepository,
    required int petId,
  })  : _petRepository = petRepository,
        _petId = petId,
        super(const PetDetailsState.loading()) {
    on<PetDetailsEvent>(
      (event, emit) => event.map(
        fetchRequested: (event) => _onFetchRequested(event, emit),
      ),
    );

    _listenPetRepository();
  }

  void _listenPetRepository(){
    _petDetailsSubscription = _petRepository.eventStream.listen((event) {
      event.mapOrNull(
        petEdited: (event) => add(PetDetailsEvent.fetchRequested(id: _petId)),
      );
    });
  }

  @override
  Future<void> close() {
    _petDetailsSubscription.cancel();
    return super.close();
  }

  Future<void> _onFetchRequested(
    PetDetailsEvent$FetchRequested event,
    Emitter<PetDetailsState> emit,
  ) async {
    try {
      emit(const PetDetailsState.loading());

      final petData = await _petRepository.getPetDetails(id: _petId);

      emit(PetDetailsState.success(petData: petData));
    } catch (e, s) {
      addError(e, s);

      emit(const PetDetailsState.error());
    }
  }
}