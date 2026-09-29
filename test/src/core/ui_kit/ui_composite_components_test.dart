import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_alphabet_index/ui_alphabet_index.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_event_tile/ui_event_tile.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stat_strip/ui_stat_strip.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  group('UiEventTile', () {
    testWidgets('показывает название и подпись и переключает выполнение', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(
          UiEventTile(
            title: 'Таблетки',
            subtitle: 'Лекарства · Мистерио',
            stripeColor: Colors.green,
            leading: const SizedBox.square(dimension: 40),
            isDone: false,
            onToggle: () => taps++,
          ),
        ),
      );

      expect(find.text('Таблетки'), findsOneWidget);
      expect(find.text('Лекарства · Мистерио'), findsOneWidget);

      await tester.tap(find.byType(GestureDetector).last);
      expect(taps, 1);
    });

    testWidgets('выполненное событие зачёркнуто', (tester) async {
      await tester.pumpWidget(
        uiTestApp(
          UiEventTile(
            title: 'Прогулка',
            subtitle: 'Прогулка · Чарли',
            stripeColor: Colors.blue,
            leading: const SizedBox.square(dimension: 40),
            isDone: true,
            onToggle: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('Прогулка'));
      final style = DefaultTextStyle.of(tester.element(find.text('Прогулка'))).style;

      expect(text.style?.decoration ?? style.decoration, TextDecoration.lineThrough);
    });
  });

  group('UiGroupedList', () {
    testWidgets('рисует разделители между строками', (tester) async {
      await tester.pumpWidget(
        uiTestApp(
          const UiGroupedList(
            children: [
              UiInfoRow(icon: Icons.cake, label: 'Дата рождения', value: '1 мая 2020'),
              UiInfoRow(icon: Icons.pets, label: 'Порода', value: 'Корги'),
              UiInfoRow(icon: Icons.scale, label: 'Вес', value: '14,9 кг'),
            ],
          ),
        ),
      );

      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.text('Корги'), findsOneWidget);
    });

    testWidgets('UiSelectableRow отмечает выбранную строку и реагирует на тап', (tester) async {
      var taps = 0;

      await tester.pumpWidget(
        uiTestApp(
          Column(
            children: [
              UiSelectableRow(label: 'Корги', selected: true, onTap: () => taps++),
              UiSelectableRow(label: 'Такса', selected: false, onTap: () {}),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Корги'));
      expect(taps, 1);
    });
  });

  testWidgets('UiStatStrip показывает подписи заглавными и значения', (tester) async {
    await tester.pumpWidget(
      uiTestApp(
        const UiStatStrip(
          items: [
            UiStatItem(label: 'Возраст', value: '3 года'),
            UiStatItem(label: 'Вес', value: '14,9 кг'),
          ],
        ),
      ),
    );

    expect(find.text('ВОЗРАСТ'), findsOneWidget);
    expect(find.text('14,9 кг'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsOneWidget);
  });

  testWidgets('UiAlphabetIndex выбирает букву по тапу и скольжению без дублей', (tester) async {
    final selected = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: UiThemeData.lightTheme,
        home: Scaffold(
          body: Center(
            child: UiAlphabetIndex(letters: const ['А', 'Б', 'В'], onLetterSelected: selected.add),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Б'));
    expect(selected, ['Б']);

    final gesture = await tester.startGesture(tester.getCenter(find.text('А')));
    final target = tester.getCenter(find.text('В'));
    await gesture.moveBy(const Offset(0, 5));
    await gesture.moveTo(target);
    await gesture.moveBy(const Offset(0, 1));
    await gesture.up();

    expect(selected.last, 'В');
  });

  group('MonthCalendar', () {
    testWidgets('показывает маркеры дня и вызывает onDateTap', (tester) async {
      DateTime? tapped;

      await tester.pumpWidget(
        uiTestApp(
          MonthCalendar(
            initialMonth: DateTime(2026, 9),
            onDateTap: (date) => tapped = date,
            style: CalendarStyle(
              resolveDateMarkers: (date) => date.day == 15 ? [Colors.red, Colors.blue] : const [],
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);

      await tester.tap(find.text('15'));
      expect(tapped, DateTime(2026, 9, 15));
    });

    testWidgets('контроллер переключает месяц снаружи, заголовок можно скрыть', (tester) async {
      final controller = MonthCalendarController(DateTime(2026, 9, 17));
      final changed = <DateTime>[];

      await tester.pumpWidget(
        uiTestApp(
          MonthCalendar(controller: controller, showHeader: false, onChangeMonth: changed.add),
        ),
      );

      expect(controller.value, DateTime(2026, 9));
      expect(find.text('30'), findsOneWidget);

      controller.nextMonth();
      await tester.pump();

      expect(changed, [DateTime(2026, 10)]);
      expect(find.text('31'), findsOneWidget);

      controller.goToMonth(DateTime(2026, 9, 29));
      await tester.pump();

      expect(controller.value, DateTime(2026, 9));
      expect(find.text('30'), findsOneWidget);
    });
  });
}
