import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_event_tile/ui_event_tile.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_bar/ui_fab.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_bar/ui_floating_nav_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stat_strip/ui_stat_strip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/pet_form_body.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/pet_details/presentation/widgets/pet_details_content.dart';

/// Проверяет, что компоненты не переполняются при максимальном системном шрифте
/// на узком экране (iPhone SE / 360 dp Android).
Widget _app(Widget child, {double textScale = 2}) => MaterialApp(
  theme: UiThemeData.lightTheme,
  locale: const Locale('ru'),
  localizationsDelegates: Localization.localizationDelegates,
  supportedLocales: Localization.supportedLocales,
  builder: (context, app) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
    child: app!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    ),
  ),
);

void main() {
  final cases = <String, Widget Function()>{
    'UiFloatingNavBar': () => UiFloatingNavBar(
      items: const [
        UiNavBarItem(icon: Icons.pets_outlined, label: 'Питомцы'),
        UiNavBarItem(icon: Icons.calendar_month_outlined, label: 'Календарь'),
        UiNavBarItem(icon: Icons.person_outline, label: 'Профиль'),
      ],
      currentIndex: 0,
      onTap: (_) {},
      action: UiFab(onPressed: () {}, semanticLabel: 'Добавить'),
    ),
    'UiEventTile': () => UiEventTile(
      title: 'Прогулка в парке с длинным названием события',
      subtitle: 'Завтра, 17:05 · Прогулка · Мистерио',
      stripeColor: Colors.green,
      leading: const SizedBox.square(dimension: 40),
      isDone: false,
      onToggle: () {},
    ),
    'UiStatStrip': () => const UiStatStrip(
      items: [
        UiStatItem(label: 'Возраст', value: '2 года 8 мес.'),
        UiStatItem(label: 'Вес', value: '14,9 кг'),
        UiStatItem(label: 'Пол', value: 'Женский'),
      ],
    ),
    'UiGroupedList': () => const UiGroupedList(
      children: [
        UiInfoRow(icon: Icons.cake_outlined, label: 'Дата рождения', value: '15.01.2024'),
        UiInfoRow(icon: Icons.badge_outlined, label: 'Порода', value: 'Метис или не знаю'),
      ],
    ),
    'UiSectionHeader': () =>
        UiSectionHeader(title: 'Ближайшие события', actionLabel: 'Изменить', onActionTap: () {}),
    'UiChip': () => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          UiChip(label: 'Все', selected: true, onTap: () {}),
          const SizedBox(width: 8),
          UiChip(label: 'Прогулка', selected: false, onTap: () {}),
        ],
      ),
    ),
    'UiButton': () => UiButton.main(label: 'Получить код', onPressed: () {}),
    'UiTextField': () => UiTextField(controller: UiTextFieldController(), labelText: 'Кличка'),
    'MonthCalendar': () => MonthCalendar(initialMonth: DateTime(2026, 9)),
    'PetFormBody': () => PetFormBody(
      petType: PetTypeEnum.cat,
      gender: PetSexEnum.male,
      nameController: UiTextFieldController(),
      breedController: UiTextFieldController(),
      birthDateController: UiTextFieldController(),
      colorController: UiTextFieldController(),
      onImageSelected: (_) {},
      onTypeChanged: (_) {},
      onSexChanged: (_) {},
      onBreedTap: () {},
      onBirthDateTap: () {},
      onWeightSelected: (_) {},
      onCastrationSelected: (_) {},
    ),
  };

  for (final entry in cases.entries) {
    testWidgets('${entry.key} не переполняется при textScale 2.0', (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(entry.value()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('PetDetailsContent не переполняется при textScale 2.0', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: UiThemeData.lightTheme,
        locale: const Locale('ru'),
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        builder: (context, app) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
          child: app!,
        ),
        home: Scaffold(
          body: PetDetailsContent(
            pet: PetDetailsModel(
              id: 1,
              petType: PetTypeEnum.dog,
              name: 'Очень длинная кличка питомца',
              breed: const BreedModel(id: 1, name: 'Метис или не знаю'),
              gender: PetSexEnum.female,
              birthday: DateTime(2020, 1, 15),
              color: 'Рыже-белый с пятнами',
              image: '',
              weight: 14.9,
              createdAt: DateTime(2024),
              updatedAt: DateTime(2024),
              hasCastration: true,
            ),
            upcomingEvents: const [],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
