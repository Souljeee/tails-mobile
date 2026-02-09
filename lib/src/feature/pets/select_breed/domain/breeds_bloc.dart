import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

part 'breeds_event.dart';
part 'breeds_state.dart';

class BreedsBloc extends Bloc<BreedsEvent, BreedsState> {
  final PetRepository _petRepository;
  BreedsBloc({
    required PetRepository petRepository,
  })  : _petRepository = petRepository,
        super(const BreedsState.loading()) {
    on<BreedsEvent>(
      (event, emit) => event.map(
        fetchRequested: (event) => _onFetchRequested(event, emit),
      ),
    );
  }

  Future<void> _onFetchRequested(
    BreedsEvent$FetchRequested event,
    Emitter<BreedsState> emit,
  ) async {
    try {
      emit(const BreedsState.loading());

      final breeds = await _petRepository.getBreeds(petType: event.petType);

      emit(BreedsState.success(breeds: breeds));
    } catch (e, s) {
      addError(e, s);

      emit(const BreedsState.error());
    }
  }
}
