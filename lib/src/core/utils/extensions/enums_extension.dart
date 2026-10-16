import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

extension ScheduleEventTypeEnumExtension on ScheduleEventTypeEnum {
  IconData get icon => switch (this) {
    ScheduleEventTypeEnum.deworming => Icons.waves_rounded,
    ScheduleEventTypeEnum.yearlyVaccination => Icons.vaccines_outlined,
    ScheduleEventTypeEnum.rabiesVaccination => Icons.science_outlined,
    ScheduleEventTypeEnum.weeklyPills => Icons.medication_outlined,
    ScheduleEventTypeEnum.dailyPills => Icons.medication_outlined,
    ScheduleEventTypeEnum.grooming => Icons.brush_outlined,
    ScheduleEventTypeEnum.bathing => Icons.bathtub_outlined,
    ScheduleEventTypeEnum.walking => Icons.route_outlined,
    ScheduleEventTypeEnum.feeding => Icons.restaurant_outlined,
    ScheduleEventTypeEnum.nailTrimming => Icons.content_cut_rounded,
    ScheduleEventTypeEnum.fleaTreatment => Icons.shield_outlined,
    ScheduleEventTypeEnum.vetVisit => Icons.medical_services_outlined,
    ScheduleEventTypeEnum.custom => Icons.more_horiz_rounded,
  };

  String getLocalizedName(AppLocalizations l10n) => switch (this) {
    ScheduleEventTypeEnum.deworming => l10n.eventTypeDeworming,
    ScheduleEventTypeEnum.yearlyVaccination => l10n.eventTypeYearlyVaccination,
    ScheduleEventTypeEnum.rabiesVaccination => l10n.eventTypeRabiesVaccination,
    ScheduleEventTypeEnum.weeklyPills => l10n.eventTypeWeeklyPills,
    ScheduleEventTypeEnum.dailyPills => l10n.eventTypeDailyPills,
    ScheduleEventTypeEnum.grooming => l10n.eventTypeGrooming,
    ScheduleEventTypeEnum.bathing => l10n.eventTypeBathing,
    ScheduleEventTypeEnum.walking => l10n.eventTypeWalking,
    ScheduleEventTypeEnum.feeding => l10n.eventTypeFeeding,
    ScheduleEventTypeEnum.nailTrimming => l10n.eventTypeNailTrimming,
    ScheduleEventTypeEnum.fleaTreatment => l10n.eventTypeFleaTreatment,
    ScheduleEventTypeEnum.vetVisit => l10n.eventTypeVetVisit,
    ScheduleEventTypeEnum.custom => l10n.eventTypeCustom,
  };
}
