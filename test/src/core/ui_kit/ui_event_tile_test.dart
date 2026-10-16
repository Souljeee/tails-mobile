import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_checkbox/ui_checkbox.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_event_tile/ui_event_tile.dart';

import '../../../helpers/ui_test_app.dart';

Widget _tile({
  UiEventTileStatus status = UiEventTileStatus.scheduled,
  VoidCallback? onTap,
  VoidCallback? onToggle,
  bool isRecurring = false,
}) => uiTestApp(
  UiEventTile(
    title: 'Таблетки',
    subtitle: 'Лекарства · Мистерио',
    stripeColor: Colors.green,
    leading: const SizedBox.square(dimension: 40),
    status: status,
    isRecurring: isRecurring,
    onTap: onTap,
    onToggle: onToggle,
    cancelledLabel: 'Отменено',
    toggleLabel: 'Отметить выполненным',
    detailsLabel: 'Открыть детали',
  ),
);

void main() {
  testWidgets('кружок и остальная карточка нажимаются независимо', (tester) async {
    var taps = 0;
    var toggles = 0;

    await tester.pumpWidget(_tile(onTap: () => taps++, onToggle: () => toggles++));

    await tester.tap(find.text('Таблетки'));
    expect((taps, toggles), (1, 0));

    await tester.tap(find.byType(UiCheckbox));
    expect((taps, toggles), (1, 1));
  });

  testWidgets('у запланированного и выполненного есть кружок, метки «Отменено» нет', (
    tester,
  ) async {
    await tester.pumpWidget(_tile());
    expect(find.byType(UiCheckbox), findsOneWidget);
    expect(find.text('Отменено'), findsNothing);

    await tester.pumpWidget(_tile(status: UiEventTileStatus.done));
    await tester.pumpAndSettle();
    expect(tester.widget<UiCheckbox>(find.byType(UiCheckbox)).isChecked, isTrue);
  });

  testWidgets('отменённое: метка вместо кружка, карточка остаётся нажимаемой', (tester) async {
    var taps = 0;

    await tester.pumpWidget(_tile(status: UiEventTileStatus.cancelled, onTap: () => taps++));
    await tester.pumpAndSettle();

    expect(find.byType(UiCheckbox), findsNothing);
    expect(find.text('Отменено'), findsOneWidget);

    await tester.tap(find.text('Таблетки'));
    expect(taps, 1);
  });

  testWidgets('значок повтора показывается только у серии', (tester) async {
    await tester.pumpWidget(_tile());
    expect(find.byIcon(Icons.repeat_rounded), findsNothing);

    await tester.pumpWidget(_tile(isRecurring: true));
    expect(find.byIcon(Icons.repeat_rounded), findsOneWidget);
  });

  testWidgets('подписи для скринридера у обеих зон', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(_tile(onTap: () {}, onToggle: () {}));

    expect(find.bySemanticsLabel(RegExp('Отметить выполненным')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Открыть детали')), findsOneWidget);
    handle.dispose();
  });
}
