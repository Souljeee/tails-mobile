import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_settings_dto.g.dart';

/// Настройки уведомлений. По умолчанию (и если сервер не прислал поле) включено всё.
@JsonSerializable()
class NotificationSettingsDto extends Equatable {
  @JsonKey(defaultValue: true)
  final bool health;
  @JsonKey(defaultValue: true)
  final bool care;
  @JsonKey(defaultValue: true)
  final bool daily;
  @JsonKey(defaultValue: true)
  final bool other;

  const NotificationSettingsDto({
    this.health = true,
    this.care = true,
    this.daily = true,
    this.other = true,
  });

  factory NotificationSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsDtoToJson(this);

  @override
  List<Object?> get props => [health, care, daily, other];
}
