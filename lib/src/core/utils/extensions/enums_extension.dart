import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

extension ScheduleEventTypeEnumExtension on ScheduleEventTypeEnum {
  IconData get icon => switch (this) {
    ScheduleEventTypeEnum.deworming => Icons.medication,
    ScheduleEventTypeEnum.yearlyVaccination => Icons.vaccines,
    ScheduleEventTypeEnum.rabiesVaccination => Icons.vaccines,
    ScheduleEventTypeEnum.weeklyPills => Icons.medication,
    ScheduleEventTypeEnum.dailyPills => Icons.medication,
    ScheduleEventTypeEnum.grooming => Icons.cleaning_services,
    ScheduleEventTypeEnum.bathing => Icons.water,
    ScheduleEventTypeEnum.walking => Icons.directions_walk,
    ScheduleEventTypeEnum.feeding => Icons.restaurant,
    ScheduleEventTypeEnum.nailTrimming => Icons.pets,
    ScheduleEventTypeEnum.fleaTreatment => Icons.bug_report,
    ScheduleEventTypeEnum.custom => Icons.pets,
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
    ScheduleEventTypeEnum.custom => l10n.eventTypeCustom,
  };
}
