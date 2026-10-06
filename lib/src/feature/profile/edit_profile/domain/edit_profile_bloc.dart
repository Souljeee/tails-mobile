import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
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

      _report(event);

      emit(const EditProfileState.success());
    } on ProfileValidationException catch (e, s) {
      addError(e, s);

      emit(const EditProfileState.error(isValidation: true));
    } catch (e, s) {
      addError(e, s);

      emit(const EditProfileState.error());
    }
  }

  /// Отправляет, что именно изменил пользователь: без имени и без самого фото.
  void _report(EditProfileEvent$SaveRequested event) {
    final removed = event.removeAvatar && event.avatar == null;
    final changed = [if (event.name != null) 'name', if (event.avatar != null || removed) 'photo'];
    if (changed.isEmpty) return;

    TailsAnalytics.log(TailsAnalyticsEvents.profileUpdated(changed: changed.join(',')));

    if (removed) {
      TailsAnalytics.log(TailsAnalyticsEvents.profilePhotoAction('remove'));
    } else if (event.avatar != null) {
      TailsAnalytics.log(
        TailsAnalyticsEvents.profilePhotoAction(event.hadAvatar ? 'change' : 'add'),
      );
    }
  }
}
