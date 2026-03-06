import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pets_repository_events.dart';

part 'pets_event.dart';
part 'pets_state.dart';

class PetsBloc extends Bloc<PetsEvent, PetsState> {
  final PetRepository _petRepository;

  late final StreamSubscription<PetsRepositoryEventsEvent> _petsRepositoryEventsSubscription;

  PetsBloc({required PetRepository petRepository})
    : _petRepository = petRepository,
      super(const PetsState.loading()) {
    on<PetsEvent>(
      (event, emit) => event.map(petsRequested: (event) => _onPetsRequested(event, emit)),
    );

    _listenPetsRepository();
  }

  @override
  Future<void> close() {
    _petsRepositoryEventsSubscription.cancel();

    return super.close();
  }

  void _listenPetsRepository() {
    _petsRepositoryEventsSubscription = _petRepository.eventStream.listen((event) {
      event.mapOrNull(
        petsAdded: (event) => add(const PetsEvent.petsRequested()),
        petEdited: (event) => add(const PetsEvent.petsRequested()),
        petDeleted: (event) => add(const PetsEvent.petsRequested()),
      );
    });
  }

  Future<void> _onPetsRequested(PetsEvent$PetsRequested event, Emitter<PetsState> emit) async {
    try {
      emit(const PetsState.loading());

      final pets = await _petRepository.getPets();

      emit(PetsState.success(pets: pets));
    } catch (e, s) {
      addError(e, s);

      emit(const PetsState.error());
    }
  }
}
