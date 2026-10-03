import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pets_repository_events.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';
import 'package:tails_mobile/src/feature/profile/profile_overview/domain/profile_overview.dart';

part 'profile_overview_event.dart';
part 'profile_overview_state.dart';

class ProfileOverviewBloc extends Bloc<ProfileOverviewEvent, ProfileOverviewState> {
  ProfileOverviewBloc({
    required ProfileRepository profileRepository,
    required PetRepository petRepository,
  }) : _profileRepository = profileRepository,
       _petRepository = petRepository,
       super(const ProfileOverviewState.loading()) {
    // Новый запрос заменяет предыдущий: на экране нужны самые свежие данные.
    on<ProfileOverviewEvent$FetchRequested>(_onFetchRequested, transformer: restartable());
    // Загрузка фото не должна отменяться обновлением данных, которое она сама вызывает.
    on<ProfileOverviewEvent$AvatarSelected>(_onAvatarSelected, transformer: droppable());

    _profileSubscription = _profileRepository.eventStream.listen((event) {
      if (event == ProfileRepositoryEvent.profileUpdated ||
          event == ProfileRepositoryEvent.notificationSettingsUpdated) {
        add(const ProfileOverviewEvent.fetchRequested(silent: true));
      }
    });
    _petsSubscription = _petRepository.eventStream.listen((_) {
      add(const ProfileOverviewEvent.fetchRequested(silent: true));
    });
  }

  final ProfileRepository _profileRepository;
  final PetRepository _petRepository;

  late final StreamSubscription<ProfileRepositoryEvent> _profileSubscription;
  late final StreamSubscription<PetsRepositoryEventsEvent> _petsSubscription;

  @override
  Future<void> close() async {
    await _profileSubscription.cancel();
    await _petsSubscription.cancel();

    return super.close();
  }

  Future<void> _onFetchRequested(
    ProfileOverviewEvent$FetchRequested event,
    Emitter<ProfileOverviewState> emit,
  ) async {
    final hasData = state is ProfileOverviewState$Success;

    try {
      if (!event.silent || !hasData) {
        emit(const ProfileOverviewState.loading());
      }

      final petsFuture = _loadPets();
      final blockedFuture = _loadBlockedBySystem();
      final profile = await _profileRepository.getProfile();
      final pets = await petsFuture;
      final blocked = await blockedFuture;

      emit(
        ProfileOverviewState.success(
          overview: ProfileOverview(
            profile: profile,
            pets: pets,
            isNotificationsBlockedBySystem: blocked,
            // Идущая загрузка фото и счётчик ошибок не должны сбрасываться обновлением данных.
            isAvatarUploading: _currentOverview?.isAvatarUploading ?? false,
            avatarUploadFailures: _currentOverview?.avatarUploadFailures ?? 0,
          ),
        ),
      );
    } catch (e, s) {
      addError(e, s);

      // При тихом обновлении оставляем уже показанные данные.
      if (!event.silent || !hasData) {
        emit(const ProfileOverviewState.error());
      }
    } finally {
      event.completer?.complete();
    }
  }

  ProfileOverview? get _currentOverview => switch (state) {
    ProfileOverviewState$Success(:final overview) => overview,
    _ => null,
  };

  Future<void> _onAvatarSelected(
    ProfileOverviewEvent$AvatarSelected event,
    Emitter<ProfileOverviewState> emit,
  ) async {
    final overview = _currentOverview;

    if (overview == null) {
      return;
    }

    try {
      emit(ProfileOverviewState.success(overview: overview.copyWith(isAvatarUploading: true)));

      await _profileRepository.updateProfile(avatar: event.avatar);
    } catch (e, s) {
      addError(e, s);

      final current = _currentOverview ?? overview;

      emit(
        ProfileOverviewState.success(
          overview: current.copyWith(
            isAvatarUploading: false,
            avatarUploadFailures: current.avatarUploadFailures + 1,
          ),
        ),
      );

      return;
    }

    // Обновление данных после успешной загрузки запускает репозиторий; на случай, если оно
    // уже отработало раньше, снимаем индикатор здесь.
    final current = _currentOverview;

    if (current != null && current.isAvatarUploading) {
      emit(ProfileOverviewState.success(overview: current.copyWith(isAvatarUploading: false)));
    }

    add(const ProfileOverviewEvent.fetchRequested(silent: true));
  }

  /// Список питомцев — второстепенная информация: ошибка не должна ломать экран.
  Future<List<PetModel>?> _loadPets() async {
    try {
      return await _petRepository.getPets();
    } catch (e, s) {
      addError(e, s);

      return null;
    }
  }

  /// Не удалось узнать состояние разрешения — считаем, что уведомления не заблокированы.
  Future<bool> _loadBlockedBySystem() async {
    try {
      return await _profileRepository.isNotificationBlockedBySystem();
    } catch (e, s) {
      addError(e, s);

      return false;
    }
  }
}
