import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/event_type_rules.dart';

/// Группа в списке выбора типа события.
enum EventTypeGroup {
  health,
  care,
  daily,
  other;

  String title(AppLocalizations l10n) => switch (this) {
    EventTypeGroup.health => l10n.eventTypeGroupHealth,
    EventTypeGroup.care => l10n.eventTypeGroupCare,
    EventTypeGroup.daily => l10n.eventTypeGroupDaily,
    EventTypeGroup.other => l10n.eventTypeGroupOther,
  };
}

/// Пункт списка выбора типа события.
class EventTypeOption {
  const EventTypeOption({required this.type, required this.group, required this.subtitleOf});

  /// Тип пункта. «Приём лекарств» представлен `dailyPills`; в API уйдёт `dailyPills` либо
  /// `weeklyPills` (см. `EventTypeRules.apiType`).
  final ScheduleEventTypeEnum type;
  final EventTypeGroup group;

  /// Подпись под названием.
  final String Function(AppLocalizations l10n) subtitleOf;

  IconData get icon => type.icon;

  String titleOf(AppLocalizations l10n) => type.getLocalizedName(l10n);
}

/// Пункты выбора типа события в порядке показа. Чтобы добавить тип, достаточно дописать элемент.
final List<EventTypeOption> eventTypeOptions = [
  EventTypeOption(
    type: ScheduleEventTypeEnum.vetVisit,
    group: EventTypeGroup.health,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleVetVisit,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.dailyPills,
    group: EventTypeGroup.health,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleMedication,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.yearlyVaccination,
    group: EventTypeGroup.health,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleYearlyVaccination,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.rabiesVaccination,
    group: EventTypeGroup.health,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleRabiesVaccination,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.fleaTreatment,
    group: EventTypeGroup.health,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleFleaTreatment,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.deworming,
    group: EventTypeGroup.health,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleDeworming,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.grooming,
    group: EventTypeGroup.care,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleGrooming,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.bathing,
    group: EventTypeGroup.care,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleBathing,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.nailTrimming,
    group: EventTypeGroup.care,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleNailTrimming,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.walking,
    group: EventTypeGroup.daily,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleWalking,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.feeding,
    group: EventTypeGroup.daily,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleFeeding,
  ),
  EventTypeOption(
    type: ScheduleEventTypeEnum.custom,
    group: EventTypeGroup.other,
    subtitleOf: (l10n) => l10n.eventTypeSubtitleCustom,
  ),
];

/// Пункт для типа (оба вида лекарств дают пункт «Приём лекарств»).
EventTypeOption eventTypeOptionOf(ScheduleEventTypeEnum type) {
  final pickerType = EventTypeRules.pickerType(type);

  return eventTypeOptions.firstWhere((option) => option.type == pickerType);
}
