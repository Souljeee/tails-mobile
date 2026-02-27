import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ScheduleEventTypeEnum {
  deworming,
  yearlyVaccination,
  rabiesVaccination,
  weeklyPills,
  dailyPills,
  grooming,
  bathing,
  walking,
  feeding,
  nailTrimming,
  fleaTreatment,
  custom,
}
