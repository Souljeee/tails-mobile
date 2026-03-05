import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ScheduleEventTypeEnum {
  // Дегельминтизация
  deworming,
  // Годовая вакцинация
  yearlyVaccination,
  // Вакцинация от бешенства
  rabiesVaccination,
  // Недельные таблетки
  weeklyPills,
  // Ежедневные таблетки
  dailyPills,
  // Уход за шерстью
  grooming,
  // Купание
  bathing,
  // Прогулка
  walking,
  // Кормление
  feeding,
  // Подрезание ногтей
  nailTrimming,
  // Лечение от блох
  fleaTreatment,
  // Пользовательское
  custom,
}
