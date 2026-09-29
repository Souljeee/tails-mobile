import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_checkbox/ui_checkbox.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_segmented_control/ui_segmented_control.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_selectable_card/ui_selectable_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_switch_row/ui_switch_row.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  group('UiCheckbox', () {
    testWidgets('вызывает onTap и показывает галочку только в отмеченном состоянии', (
      tester,
    ) async {
      var taps = 0;

      await tester.pumpWidget(uiTestApp(UiCheckbox(isChecked: false, onTap: () => taps++)));

      expect(find.byIcon(Icons.check_rounded), findsNothing);

      await tester.tap(find.byType(UiCheckbox));

      expect(taps, 1);

      await tester.pumpWidget(uiTestApp(UiCheckbox(isChecked: true, onTap: () => taps++)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('область касания не меньше 44×44', (tester) async {
      await tester.pumpWidget(uiTestApp(const UiCheckbox(isChecked: false)));

      expect(tester.getSize(find.byType(UiCheckbox)), const Size.square(44));
    });
  });

  group('UiSwitchRow', () {
    testWidgets('показывает тексты и переключает значение', (tester) async {
      bool? value;

      await tester.pumpWidget(
        uiTestApp(
          UiSwitchRow(
            title: 'Стерилизована',
            subtitle: 'Можно изменить позже в профиле',
            value: false,
            onChanged: (newValue) => value = newValue,
          ),
        ),
      );

      expect(find.text('Стерилизована'), findsOneWidget);
      expect(find.text('Можно изменить позже в профиле'), findsOneWidget);

      await tester.tap(find.byType(Switch));

      expect(value, true);
    });
  });

  group('UiSelectableCard', () {
    testWidgets('вызывает onTap и показывает подпись', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(
          UiSelectableCard(label: 'Кошка', selected: false, icon: Icons.pets, onTap: () => taps++),
        ),
      );
      await tester.tap(find.text('Кошка'));

      expect(taps, 1);
      expect(find.byIcon(Icons.pets), findsOneWidget);
    });
  });

  group('UiSegmentedControl', () {
    testWidgets('сообщает о выборе сегмента', (tester) async {
      String? selected;

      await tester.pumpWidget(
        uiTestApp(
          UiSegmentedControl<String>(
            options: const [
              UiSegmentedOption(value: 'overview', label: 'Обзор'),
              UiSegmentedOption(value: 'health', label: 'Здоровье'),
            ],
            selected: 'overview',
            onChanged: (value) => selected = value,
          ),
        ),
      );
      await tester.tap(find.text('Здоровье'));

      expect(selected, 'health');
    });
  });
}
