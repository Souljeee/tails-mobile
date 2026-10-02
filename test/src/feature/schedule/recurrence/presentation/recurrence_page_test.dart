import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_day_toggle/ui_day_toggle.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_page.dart';

import '../../../../../helpers/ui_test_app.dart';

void main() {
  // 5 октября 2026 — понедельник.
  final draft = RecurrenceDraft.initial(eventDate: DateTime(2026, 10, 5), eventTime: '09:00');

  Widget page({
    RecurrenceDraft? initial,
    ValueChanged<RecurrenceDraft?>? onApply,
    VoidCallback? onBack,
  }) => uiTestApp(
    RecurrencePage(initial: initial ?? draft, onApply: onApply ?? (_) {}, onBack: onBack ?? () {}),
  );

  testWidgets('показывает итог и ближайшие даты', (tester) async {
    await tester.pumpWidget(page());

    expect(find.text('Каждый день'), findsWidgets);
    expect(find.text('Ближайшие: 05.10, 06.10, 07.10'), findsOneWidget);
  });

  testWidgets('переключение на «Неделя» показывает дни недели и меняет итог', (tester) async {
    await tester.pumpWidget(page());

    await tester.tap(find.text('Неделя'));
    await tester.pumpAndSettle();

    expect(find.byType(UiDayToggle), findsNWidgets(7));
    expect(find.text('Каждый понедельник'), findsOneWidget);

    await tester.tap(find.text('Вт'));
    await tester.pumpAndSettle();

    expect(find.text('Каждый понедельник'), findsNothing);
  });

  testWidgets('«Готово» отдаёт черновик, «Не повторять» — null, «Отмена» — назад', (tester) async {
    RecurrenceDraft? applied;
    var applyCalls = 0;
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var backCalls = 0;

    await tester.pumpWidget(
      page(
        onApply: (value) {
          applied = value;
          applyCalls++;
        },
        onBack: () => backCalls++,
      ),
    );

    await tester.tap(find.text('Готово'));
    expect(applyCalls, 1);
    expect(applied?.period, RecurrencePeriod.day);

    await tester.tap(find.text('Не повторять'));
    expect(applyCalls, 2);
    expect(applied, isNull);

    await tester.tap(find.text('Отмена'));
    expect(backCalls, 1);
  });

  testWidgets('«Раз в день» = 2 раскладывает времена и открывает барабан', (tester) async {
    RecurrenceDraft? applied;

    await tester.pumpWidget(page(onApply: (value) => applied = value));
    await tester.tap(find.byIcon(Icons.add_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('Время 1'), findsOneWidget);
    expect(find.text('Время 2'), findsOneWidget);

    await tester.tap(find.text('Готово'));
    expect(applied?.times.length, 2);
  });

  testWidgets('без времени события вместо «Раз в день» — подсказка', (tester) async {
    await tester.pumpWidget(
      page(initial: RecurrenceDraft.initial(eventDate: DateTime(2026, 10, 5))),
    );

    expect(find.textContaining('Укажите время события'), findsOneWidget);
  });

  testWidgets('«Окончание → В дату» по умолчанию допустимо и не блокирует «Готово»', (
    tester,
  ) async {
    var applyCalls = 0;
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(page(onApply: (_) => applyCalls++));

    await tester.tap(find.text('Окончание'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('В дату'));
    await tester.pumpAndSettle();
    // Дата по умолчанию — первое повторение, поэтому ошибки нет.
    await tester.tap(find.text('Готово'));
    expect(applyCalls, 1);
  });

  testWidgets('помещается на узком экране с крупным шрифтом', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: page(initial: draft.withPeriod(RecurrencePeriod.month)),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
