import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_day_toggle/ui_day_toggle.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_wheel_panel/ui_wheel_panel.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_page.dart';

import '../../../../../helpers/ui_test_app.dart';

void main() {
  // 5 октября 2026 — понедельник.
  final draft = RecurrenceDraft.initial(eventDate: DateTime(2026, 10, 5), eventTime: '09:00');

  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Widget page({
    RecurrenceDraft? initial,
    ValueChanged<RecurrenceDraft?>? onApply,
    VoidCallback? onBack,
  }) => uiTestApp(
    RecurrencePage(initial: initial ?? draft, onApply: onApply ?? (_) {}, onBack: onBack ?? () {}),
  );

  testWidgets('показывает итог, время и ближайшие даты плашками', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(page());

    expect(find.text('Каждый день'), findsWidgets);
    expect(find.text('в 09:00'), findsOneWidget);
    expect(find.text('пн 5 окт'), findsOneWidget);
    expect(find.text('вт 6 окт'), findsOneWidget);
    expect(find.text('ср 7 окт'), findsOneWidget);
    expect(find.text('Как в событии'), findsOneWidget);
  });

  testWidgets('«Неделя»: дни недели, пресеты, подсказка про время события', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(page());

    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();

    expect(find.byType(UiDayToggle), findsNWidgets(7));
    expect(find.text('Каждый понедельник'), findsOneWidget);
    expect(find.text('В 09:00 — время из события'), findsOneWidget);

    await tester.tap(find.text('Будни'));
    await tester.pumpAndSettle();

    expect(find.text('По будням'), findsOneWidget);
  });

  testWidgets('«Месяц»: выбранные числа и сетка по «Изменить»', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(page(initial: draft.withPeriod(RecurrencePeriod.month)));

    expect(find.byType(UiDayToggle), findsOneWidget);
    await tester.tap(find.text('Изменить'));
    await tester.pumpAndSettle();

    expect(find.byType(UiDayToggle), findsNWidgets(31));
    await tester.tap(find.text('31'));
    await tester.pumpAndSettle();
    expect(find.textContaining('30 ноября и 28 февраля'), findsOneWidget);

    await tester.tap(find.text('Свернуть'));
    await tester.pumpAndSettle();
    expect(find.byType(UiDayToggle), findsNWidgets(2));
  });

  testWidgets('«Год»: список дат и добавление через барабан', (tester) async {
    RecurrenceDraft? applied;
    useTallScreen(tester);
    await tester.pumpWidget(
      page(initial: draft.withPeriod(RecurrencePeriod.year), onApply: (value) => applied = value),
    );

    expect(find.text('5 октября'), findsOneWidget);
    await tester.tap(find.text('Добавить дату'));
    await tester.pumpAndSettle();
    expect(find.text('Новая дата'), findsOneWidget);

    await tester.tap(find.text('Добавить'));
    await tester.pumpAndSettle();
    // Дата по умолчанию совпала с уже выбранной — второй не появляется (она снимается).
    expect(find.text('Новая дата'), findsNothing);

    await tester.tap(find.text('Сохранить'));
    expect(applied, isNotNull);
  });

  testWidgets('«Сохранить» отдаёт черновик, «Не повторять» — null, «назад» — onBack', (
    tester,
  ) async {
    RecurrenceDraft? applied;
    var applyCalls = 0;
    var backCalls = 0;
    useTallScreen(tester);

    await tester.pumpWidget(
      page(
        onApply: (value) {
          applied = value;
          applyCalls++;
        },
        onBack: () => backCalls++,
      ),
    );

    await tester.tap(find.text('Сохранить'));
    expect(applyCalls, 1);
    expect(applied?.period, RecurrencePeriod.day);

    await tester.tap(find.text('Не повторять'));
    expect(applyCalls, 2);
    expect(applied, isNull);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    expect(backCalls, 1);
  });

  testWidgets('«3 раза в день»: плитки времени и барабан вместо «Сохранить»', (tester) async {
    RecurrenceDraft? applied;
    useTallScreen(tester);
    await tester.pumpWidget(page(onApply: (value) => applied = value));

    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('3 раза в день'), findsWidgets);
    expect(find.text('Время 2'), findsOneWidget);

    await tester.tap(find.text('Время 2'));
    await tester.pumpAndSettle();
    expect(find.byType(UiWheelPanel), findsOneWidget);
    expect(find.text('Сохранить'), findsNothing);
    expect(find.text('Удалить'), findsOneWidget);

    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();
    expect(find.byType(UiWheelPanel), findsNothing);

    await tester.tap(find.text('Сохранить'));
    expect(applied?.times.length, 3);
  });

  testWidgets('без времени события блок «В течение дня» скрыт', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      page(initial: RecurrenceDraft.initial(eventDate: DateTime(2026, 10, 5))),
    );

    expect(find.text('В течение дня'), findsNothing);
    expect(find.text('Как в событии'), findsNothing);
  });

  testWidgets('«Окончание → До определённой даты» подставляет дату первого повторения', (
    tester,
  ) async {
    RecurrenceDraft? applied;
    useTallScreen(tester);
    await tester.pumpWidget(page(onApply: (value) => applied = value));

    await tester.tap(find.text('Окончание'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('До определённой даты'));
    await tester.pumpAndSettle();

    expect(find.text('05.10.2026'), findsWidgets);
    await tester.tap(find.text('Сохранить'));
    expect(applied?.end, isA<RecurrenceEnd$Until>());
  });

  testWidgets('помещается на узком экране с крупным шрифтом', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final period in RecurrencePeriod.values.where((p) => p != RecurrencePeriod.unknown)) {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: page(initial: draft.withPeriod(period)),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: '$period');
    }
  });
}
