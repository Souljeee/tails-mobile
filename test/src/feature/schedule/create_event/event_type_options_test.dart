import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations_ru.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/utils/event_type_options.dart';

void main() {
  final l10n = AppLocalizationsRu();

  test('чипы типа события: подписи и отправляемые типы', () {
    final labels = {for (final option in eventTypeOptions) option.labelOf(l10n): option.type};

    expect(labels, {
      'Прогулка': ScheduleEventTypeEnum.walking,
      'Кормление': ScheduleEventTypeEnum.feeding,
      'Лекарства': ScheduleEventTypeEnum.dailyPills,
      'Время': ScheduleEventTypeEnum.custom,
    });
  });

  test('типы в чипах не повторяются', () {
    final types = eventTypeOptions.map((option) => option.type).toList();

    expect(types.toSet().length, types.length);
  });
}
