import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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

      emit(state.copyWith(status: DeleteAccountStatus.deleted));
    } on InvalidDeletionCodeException catch (e) {
      emit(
        state.copyWith(
          status: DeleteAccountStatus.failure,
          failure: DeleteAccountFailure.invalidCode,
          failureMessage: e.message,
        ),
      );
    } catch (e, s) {
      addError(e, s);

      emit(
        state.copyWith(status: DeleteAccountStatus.failure, failure: DeleteAccountFailure.generic),
      );
    }
  }
}
