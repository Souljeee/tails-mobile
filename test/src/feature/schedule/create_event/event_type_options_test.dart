import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations_ru.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/utils/event_type_options.dart';

void main() {
  final l10n = AppLocalizationsRu();

  test('справочник типов: группы, названия и отправляемые типы по макету', () {
    final byGroup = <EventTypeGroup, Map<String, ScheduleEventTypeEnum>>{};
    for (final option in eventTypeOptions) {
      (byGroup[option.group] ??= {})[option.titleOf(l10n)] = option.type;
    }

    expect(byGroup, {
      EventTypeGroup.health: {
        'Визит к ветеринару': ScheduleEventTypeEnum.vetVisit,
        'Приём лекарств': ScheduleEventTypeEnum.dailyPills,
        'Плановая вакцинация': ScheduleEventTypeEnum.yearlyVaccination,
        'Прививка от бешенства': ScheduleEventTypeEnum.rabiesVaccination,
        'Обработка от блох': ScheduleEventTypeEnum.fleaTreatment,
        'Обработка от глистов': ScheduleEventTypeEnum.deworming,
      },
      EventTypeGroup.care: {
        'Уход за шерстью': ScheduleEventTypeEnum.grooming,
        'Купание': ScheduleEventTypeEnum.bathing,
        'Стрижка когтей': ScheduleEventTypeEnum.nailTrimming,
      },
      EventTypeGroup.daily: {
        'Прогулка': ScheduleEventTypeEnum.walking,
        'Кормление': ScheduleEventTypeEnum.feeding,
      },
      EventTypeGroup.other: {'Другое': ScheduleEventTypeEnum.custom},
    });
  });

  test('типы в списке не повторяются, у каждого есть подпись', () {
    final types = eventTypeOptions.map((option) => option.type).toList();

    expect(types.toSet().length, types.length);
    for (final option in eventTypeOptions) {
      expect(option.subtitleOf(l10n), isNotEmpty);
    }
  });

  test('недельные таблетки отображаются как «Приём лекарств»', () {
    expect(eventTypeOptionOf(ScheduleEventTypeEnum.weeklyPills).titleOf(l10n), 'Приём лекарств');
  });
}
