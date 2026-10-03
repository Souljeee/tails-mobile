import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/profile_model.dart';

/// Данные экрана «Профиль».
class ProfileOverview extends Equatable {
  const ProfileOverview({
    required this.profile,
    this.pets,
    this.isNotificationsBlockedBySystem = false,
    this.isAvatarUploading = false,
    this.avatarUploadFailures = 0,
  });

  final ProfileModel profile;

  /// Питомцы пользователя; `null`, если список не удалось загрузить.
  final List<PetModel>? pets;

  /// Уведомления запрещены в настройках телефона.
  final bool isNotificationsBlockedBySystem;

  /// Фото, выбранное на экране профиля, ещё отправляется на сервер.
  final bool isAvatarUploading;

  /// Сколько раз не удалось загрузить фото; экран показывает ошибку при росте.
  final int avatarUploadFailures;

  int? get petsCount => pets?.length;

  ProfileOverview copyWith({bool? isAvatarUploading, int? avatarUploadFailures}) => ProfileOverview(
    profile: profile,
    pets: pets,
    isNotificationsBlockedBySystem: isNotificationsBlockedBySystem,
    isAvatarUploading: isAvatarUploading ?? this.isAvatarUploading,
    avatarUploadFailures: avatarUploadFailures ?? this.avatarUploadFailures,
  );

  @override
  List<Object?> get props => [
    profile,
    pets,
    isNotificationsBlockedBySystem,
    isAvatarUploading,
    avatarUploadFailures,
  ];
}
