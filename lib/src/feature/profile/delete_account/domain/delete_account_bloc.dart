import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/analytics/analytics_reason_mapper.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/exceptions/profile_exceptions.dart';

part 'delete_account_event.dart';
part 'delete_account_state.dart';

class DeleteAccountBloc extends Bloc<DeleteAccountEvent, DeleteAccountState> {
  DeleteAccountBloc({
    required ProfileRepository profileRepository,
    required PetRepository petRepository,
  }) : _profileRepository = profileRepository,
       _petRepository = petRepository,
       super(const DeleteAccountState()) {
    on<DeleteAccountEvent>(
      (event, emit) => event.map(
        started: (event) => _onStarted(event, emit),
        sendCodeRequested: (event) => _onSendCodeRequested(event, emit),
        deleteRequested: (event) => _onDeleteRequested(event, emit),
      ),
    );
  }

  final ProfileRepository _profileRepository;
  final PetRepository _petRepository;

  Future<void> _onStarted(
    DeleteAccountEvent$Started event,
    Emitter<DeleteAccountState> emit,
  ) async {
    TailsAnalytics.log(TailsAnalyticsEvents.accountDeleteStarted);

    try {
      final pets = await _petRepository.getPets();

      emit(state.copyWith(petNames: [for (final pet in pets) pet.name]));
    } catch (e, s) {
      // Без списка питомцев предупреждение остаётся, просто без имён.
      addError(e, s);
    }
  }

  Future<void> _onSendCodeRequested(
    DeleteAccountEvent$SendCodeRequested event,
    Emitter<DeleteAccountState> emit,
  ) async {
    if (state.isBusy) {
      return;
    }

    try {
      emit(state.copyWith(status: DeleteAccountStatus.sendingCode));

      await _profileRepository.sendDeletionCode();

      emit(state.copyWith(status: DeleteAccountStatus.codeSent));
    } on DeletionCodeTooSoonException {
      // Код уже отправлен меньше минуты назад и действует — можно переходить к вводу.
      emit(state.copyWith(status: DeleteAccountStatus.codeSent, wasCodeAlreadySent: true));
    } catch (e, s) {
      addError(e, s);

      emit(
        state.copyWith(status: DeleteAccountStatus.failure, failure: DeleteAccountFailure.generic),
      );
    }
  }

  Future<void> _onDeleteRequested(
    DeleteAccountEvent$DeleteRequested event,
    Emitter<DeleteAccountState> emit,
  ) async {
    if (state.isBusy || state.status == DeleteAccountStatus.deleted) {
      return;
    }

    try {
      emit(state.copyWith(status: DeleteAccountStatus.deleting));

      await _profileRepository.deleteAccount(code: event.code);

      TailsAnalytics.log(
        TailsAnalyticsEvents.accountDeleted(
          petsCount: _petRepository.knownPetsCount ?? state.petNames.length,
        ),
      );

      emit(state.copyWith(status: DeleteAccountStatus.deleted));
    } on InvalidDeletionCodeException catch (e) {
      TailsAnalytics.log(TailsAnalyticsEvents.accountDeleteFailed(AnalyticsReason.invalidCode));

      emit(
        state.copyWith(
          status: DeleteAccountStatus.failure,
          failure: DeleteAccountFailure.invalidCode,
          failureMessage: e.message,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      TailsAnalytics.log(TailsAnalyticsEvents.accountDeleteFailed(analyticsReasonOf(e)));

      emit(
        state.copyWith(status: DeleteAccountStatus.failure, failure: DeleteAccountFailure.generic),
      );
    }
  }
}
