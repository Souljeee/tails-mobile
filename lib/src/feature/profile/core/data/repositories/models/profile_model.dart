import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/dtos/profile_dto.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/notification_settings_model.dart';

class ProfileModel extends Equatable {
  const ProfileModel({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.notificationSettings,
    this.avatarUrl,
  });

  factory ProfileModel.fromDto(ProfileDto dto) => ProfileModel(
    id: dto.id,
    phoneNumber: dto.phoneNumber,
    name: dto.name.trim(),
    avatarUrl: dto.avatar,
    notificationSettings: NotificationSettingsModel.fromDto(dto.notificationSettings),
  );

  final String id;

  /// Номер так, как его хранит сервер (`79990001122`); для показа — `formatPhoneForDisplay`.
  final String phoneNumber;

  /// Имя; пустая строка, если пользователь его не указал.
  final String name;
  final String? avatarUrl;
  final NotificationSettingsModel notificationSettings;

  bool get hasName => name.isNotEmpty;

  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  @override
  List<Object?> get props => [id, phoneNumber, name, avatarUrl, notificationSettings];
}
