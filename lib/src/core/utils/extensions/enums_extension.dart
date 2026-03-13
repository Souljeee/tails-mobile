import 'package:flutter/material.dart';
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
}