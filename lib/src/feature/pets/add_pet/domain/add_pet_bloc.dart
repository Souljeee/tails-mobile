import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/analytics/analytics_reason_mapper.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/add_pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

part 'add_pet_event.dart';
part 'add_pet_state.dart';

class AddPetBloc extends Bloc<AddPetEvent, AddPetState> {
  final PetRepository _petRepository;
  AddPetBloc({required PetRepository petRepository})
    : _petRepository = petRepository,
      super(const AddPetState.initial()) {
    on<AddPetEvent>(
      (event, emit) => event.map(addingRequested: (event) => _onAddingRequested(event, emit)),
    );
  }

  Future<void> _onAddingRequested(
    AddPetEvent$AddingRequested event,
    Emitter<AddPetState> emit,
  ) async {
    try {
      emit(const AddPetState.loading());

      final countBefore = _petRepository.knownPetsCount;

      await _petRepository.addPet(
        model: AddPetModel(
          name: event.name,
          petType: event.petType,
          breedId: event.breedId,
          color: event.color,
          weight: event.weight,
          gender: event.gender,
          birthday: event.birthday,
          hasCastration: event.castration,
        ),
        image: event.image,
      );

      TailsAnalytics.log(
        TailsAnalyticsEvents.petCreated(
          petType: event.petType.name,
          sex: event.gender.name,
          isMixed: event.isMixedBreed,
          hasPhoto: event.image != null,
          isCastrated: event.castration,
          ageBucket: TailsAnalyticsEvents.ageBucketOf(event.birthday, now: clock.now()),
          petsCount: countBefore == null ? null : countBefore + 1,
          isFirstPet: countBefore == null ? null : countBefore == 0,
        ),
      );

      emit(const AddPetState.success());
    } catch (e, s) {
      addError(e, s);
      TailsAnalytics.log(TailsAnalyticsEvents.petCreateFailed(analyticsReasonOf(e)));

      emit(const AddPetState.error());
    } finally {
      emit(const AddPetState.initial());
    }
  }
}
