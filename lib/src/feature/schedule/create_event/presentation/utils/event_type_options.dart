import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

/// Чип выбора типа события в форме создания.
class EventTypeOption {
  const EventTypeOption({required this.type, required this.icon, required this.labelOf});

  /// Тип, который уходит в API.
  final ScheduleEventTypeEnum type;
  final IconData icon;

  /// Локализованная подпись чипа.
  final String Function(AppLocalizations l10n) labelOf;
}

/// Список чипов типа события. Чтобы добавить чип, достаточно дописать элемент.
///
/// TODO: полный список типов и соответствие чипа «Время» типу события появятся вместе
/// с дизайном и API; пока «Время» отправляет `custom`.
final List<EventTypeOption> eventTypeOptions = [
  EventTypeOption(
    type: ScheduleEventTypeEnum.walking,
    icon: ScheduleEventTypeEnum.walking.icon,
    labelOf: ScheduleEventTypeEnum.walking.getLocalizedName,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.feeding,
    icon: ScheduleEventTypeEnum.feeding.icon,
    labelOf: ScheduleEventTypeEnum.feeding.getLocalizedName,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.dailyPills,
    icon: ScheduleEventTypeEnum.dailyPills.icon,
    labelOf: ScheduleEventTypeEnum.dailyPills.getLocalizedName,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.custom,
    icon: Icons.schedule,
    labelOf: (l10n) => l10n.eventChipTime,
  ),
];
