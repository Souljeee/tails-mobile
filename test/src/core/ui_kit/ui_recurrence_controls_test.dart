import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_day_toggle/ui_day_toggle.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_expandable_card/ui_expandable_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_hint_banner/ui_hint_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stepper/ui_stepper.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_wheel_panel/ui_wheel_panel.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  group('UiStepper', () {
    testWidgets('меняет значение и блокирует границы', (tester) async {
      var value = 1;
      late StateSetter set;
      await tester.pumpWidget(
        uiTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return UiStepper(value: value, max: 2, onChanged: (v) => set(() => value = v));
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove_rounded));
      expect(value, 1);
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(value, 2);
      await tester.tap(find.byIcon(Icons.add_rounded));
      expect(value, 2);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('UiDayToggle', () {
    testWidgets('нажимается, область 44×44', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        uiTestApp(UiDayToggle(label: 'Пн', selected: true, onTap: () => taps++)),
      );

      expect(tester.getSize(find.byType(UiDayToggle)), const Size.square(44));
      await tester.tap(find.text('Пн'));
      expect(taps, 1);
    });
  });

  group('UiHintBanner', () {
    testWidgets('показывает текст при крупном шрифте и тёмной теме', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: uiTestApp(
            const UiHintBanner(text: 'В коротких месяцах — в последний день'),
            theme: UiThemeData.darkTheme,
          ),
        ),
      );

      expect(find.text('В коротких месяцах — в последний день'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('UiExpandableCard', () {
    testWidgets('раскрывает содержимое по нажатию', (tester) async {
      var expanded = false;
      late StateSetter set;
      await tester.pumpWidget(
        uiTestApp(
          StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return UiExpandableCard(
                title: 'Окончание',
                value: 'Никогда',
                expanded: expanded,
                onToggle: () => set(() => expanded = !expanded),
                child: const Text('Содержимое'),
              );
            },
          ),
        ),
      );

      expect(find.text('Никогда'), findsOneWidget);
      expect(find.text('Содержимое'), findsNothing);
      await tester.tap(find.text('Окончание'));
      await tester.pumpAndSettle();
      expect(find.text('Содержимое'), findsOneWidget);
      expect(find.text('Никогда'), findsNothing);
    });
  });

  group('UiWheelPanel', () {
    testWidgets('сообщает о выборе пункта', (tester) async {
      int? selected;
      var applied = 0;
      await tester.pumpWidget(
        uiTestApp(
          UiWheelPanel(
            title: 'Время 1',
            rightLabel: 'Применить',
            onRight: () => applied++,
            columns: [
              UiWheelColumn(
                labels: const ['00', '01', '02', '03'],
                selectedIndex: 0,
                onSelected: (i) => selected = i,
              ),
            ],
          ),
        ),
      );

      await tester.drag(find.text('00'), const Offset(0, -UiWheelPanel.itemExtent * 2));
      await tester.pumpAndSettle();
      expect(selected, 2);

      await tester.tap(find.text('Применить'));
      expect(applied, 1);
    });

    testWidgets('между барабанами без разделителя есть отступ', (tester) async {
      await tester.pumpWidget(
        uiTestApp(
          UiWheelPanel(
            title: 'Новая дата',
            rightLabel: 'Добавить',
            onRight: () {},
            columns: [
              UiWheelColumn(
                labels: const ['1', '2', '3'],
                selectedIndex: 0,
                alignment: Alignment.centerRight,
                onSelected: (_) {},
              ),
              UiWheelColumn(
                labels: const ['июля', 'августа', 'сентября'],
                selectedIndex: 0,
                alignment: Alignment.centerLeft,
                onSelected: (_) {},
              ),
            ],
          ),
        ),
      );

      final day = tester.getRect(find.text('1'));
      final month = tester.getRect(find.text('июля'));
      expect(month.left - day.right, greaterThanOrEqualTo(24));
    });
  });
}
