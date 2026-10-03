import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_settings_dto.g.dart';

/// Настройки уведомлений. По умолчанию (и если сервер не прислал поле) включено всё.
@JsonSerializable()
class NotificationSettingsDto extends Equatable {
  @JsonKey(defaultValue: true)
  final bool walks;
  @JsonKey(defaultValue: true)
  final bool feeding;
  @JsonKey(defaultValue: true)
  final bool medications;
  @JsonKey(defaultValue: true)
  final bool vaccinations;
  @JsonKey(defaultValue: true)
  final bool vetVisits;

  const NotificationSettingsDto({
    this.walks = true,
    this.feeding = true,
    this.medications = true,
    this.vaccinations = true,
    this.vetVisits = true,
  });

  factory NotificationSettingsDto.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationSettingsDtoToJson(this);

  @override
  List<Object?> get props => [walks, feeding, medications, vaccinations, vetVisits];
}
