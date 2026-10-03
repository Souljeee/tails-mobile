import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/dtos/notification_settings_dto.dart';

part 'profile_dto.g.dart';

@JsonSerializable()
class ProfileDto extends Equatable {
  final String id;
  final String phoneNumber;

  /// Имя необязательно: у старых пользователей и после очистки оно пустое.
  @JsonKey(defaultValue: '')
  final String name;

  /// Абсолютный адрес фото или `null`.
  final String? avatar;

  /// Нет в ответе старых версий API — тогда считаем, что включено всё.
  final NotificationSettingsDto? notificationSettings;

  const ProfileDto({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.avatar,
    this.notificationSettings,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) => _$ProfileDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileDtoToJson(this);

  @override
  List<Object?> get props => [id, phoneNumber, name, avatar, notificationSettings];
}
