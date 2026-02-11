import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pets_repository_events.dart';

part 'pets_list_event.dart';
part 'pets_list_state.dart';

class PetsListBloc extends Bloc<PetsListEvent, PetsListState> {
  final PetRepository _petRepository;

  late final StreamSubscription<PetsRepositoryEventsEvent> _petsRepositoryEventsSubscription;

  PetsListBloc({
    required PetRepository petRepository,
  })  : _petRepository = petRepository,
        super(const PetsListState.loading()) {
    on<PetsListEvent>(
      (event, emit) => event.map(
        fetchRequested: (event) => _onFetchRequested(event, emit),
      ),
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
        petsAdded: (event) => add(const PetsListEvent.fetchRequested()),
      );
    });
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
