import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/exceptions/profile_exceptions.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const EditProfileState.initial()) {
    on<EditProfileEvent>(
      (event, emit) => event.map(saveRequested: (event) => _onSaveRequested(event, emit)),
    );
  }

  final ProfileRepository _profileRepository;

  Future<void> _onSaveRequested(
    EditProfileEvent$SaveRequested event,
    Emitter<EditProfileState> emit,
  ) async {
    if (state is EditProfileState$Loading) {
      return;
    }

    try {
      emit(const EditProfileState.loading());

      // Новое фото заменяет старое само, удалять его отдельно нужно только без замены.
      if (event.removeAvatar && event.avatar == null) {
        await _profileRepository.deleteAvatar();
      }

      if (event.name != null || event.avatar != null) {
        await _profileRepository.updateProfile(name: event.name, avatar: event.avatar);
      }

      emit(const EditProfileState.success());
    } on ProfileValidationException catch (e, s) {
      addError(e, s);

      emit(const EditProfileState.error(isValidation: true));
    } catch (e, s) {
      addError(e, s);

      emit(const EditProfileState.error());
    }
  }
}
