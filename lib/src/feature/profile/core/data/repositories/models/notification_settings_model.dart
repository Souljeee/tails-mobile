import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/dtos/notification_settings_dto.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';

/// Какие категории уведомлений включены.
class NotificationSettingsModel extends Equatable {
  const NotificationSettingsModel({required this.enabled});

  /// Включено всё — состояние по умолчанию.
  factory NotificationSettingsModel.allEnabled() =>
      NotificationSettingsModel(enabled: {for (final c in NotificationCategory.values) c: true});

  factory NotificationSettingsModel.fromDto(NotificationSettingsDto? dto) {
    final source = dto ?? const NotificationSettingsDto();

    return NotificationSettingsModel(
      enabled: {
        NotificationCategory.walks: source.walks,
        NotificationCategory.feeding: source.feeding,
        NotificationCategory.medications: source.medications,
        NotificationCategory.vaccinations: source.vaccinations,
        NotificationCategory.vetVisits: source.vetVisits,
      },
    );
  }

  final Map<NotificationCategory, bool> enabled;

  bool isEnabled(NotificationCategory category) => enabled[category] ?? true;

  bool get isAllDisabled => NotificationCategory.values.every((c) => !isEnabled(c));

  NotificationSettingsModel copyWith({
    required NotificationCategory category,
    required bool value,
  }) => NotificationSettingsModel(enabled: {...enabled, category: value});

  @override
  List<Object?> get props => [
    for (final category in NotificationCategory.values) isEnabled(category),
  ];
}
