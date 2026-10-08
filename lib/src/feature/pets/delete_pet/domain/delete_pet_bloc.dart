import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/analytics/analytics_reason_mapper.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/logging/tails_loggable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';

part 'delete_pet_event.dart';
part 'delete_pet_state.dart';

class DeletePetBloc extends Bloc<DeletePetEvent, DeletePetState> {
  final PetRepository _petRepository;

  DeletePetBloc({required PetRepository petRepository})
    : _petRepository = petRepository,
      super(const DeletePetState.initial()) {
    on<DeletePetEvent>(
      (event, emit) => event.map(deleteRequested: (event) => _onDeleteRequested(event, emit)),
    );
  }

  Future<void> _onDeleteRequested(
    DeletePetEvent$DeleteRequested event,
    Emitter<DeletePetState> emit,
  ) async {
    try {
      emit(const DeletePetState.loading());

      await _petRepository.deletePet(id: event.id);

      TailsAnalytics.log(TailsAnalyticsEvents.petDeleted);

      emit(const DeletePetState.success());
    } catch (e, s) {
      addError(e, s);
      TailsAnalytics.log(TailsAnalyticsEvents.petDeleteFailed(analyticsReasonOf(e)));

      emit(const DeletePetState.error());
    } finally {
      emit(const DeletePetState.initial());
    }
  }
}
