import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_bar/ui_fab.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_bar/ui_floating_nav_bar.dart';

import '../../../helpers/ui_test_app.dart';

const _items = [
  UiNavBarItem(icon: Icons.pets_outlined, activeIcon: Icons.pets, label: 'Питомцы'),
  UiNavBarItem(icon: Icons.calendar_month_outlined, label: 'Календарь'),
  UiNavBarItem(icon: Icons.person_outline, label: 'Профиль'),
];

Widget _bar({
  int currentIndex = 0,
  ValueChanged<int>? onTap,
  VoidCallback? onAction,
  bool showAction = true,
}) => uiTestApp(
  Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: UiFloatingNavBar(
      items: _items,
      currentIndex: currentIndex,
      onTap: onTap ?? (_) {},
      showAction: showAction,
      action: UiFab(onPressed: onAction, semanticLabel: 'Добавить'),
    ),
  ),
);

void main() {
  group('UiFloatingNavBar', () {
    testWidgets('показывает подписи всех вкладок', (tester) async {
      await tester.pumpWidget(_bar());

      expect(find.text('Питомцы'), findsOneWidget);
      expect(find.text('Календарь'), findsOneWidget);
      expect(find.text('Профиль'), findsOneWidget);
    });

    testWidgets('вызывает onTap с индексом вкладки', (tester) async {
      int? tapped;

      await tester.pumpWidget(_bar(onTap: (index) => tapped = index));
      await tester.tap(find.text('Календарь'));

      expect(tapped, 1);
    });

    testWidgets('кнопка действия нажимается, пока она показана', (tester) async {
      var taps = 0;

      await tester.pumpWidget(_bar(onAction: () => taps++));
      await tester.tap(find.byType(UiFab));

      expect(taps, 1);
    });

    testWidgets('при showAction=false кнопка не нажимается, а пилюля растягивается', (
      tester,
    ) async {
      var taps = 0;

      await tester.pumpWidget(_bar(onAction: () => taps++));

      final narrowWidth = tester.getSize(find.byKey(UiFloatingNavBar.pillKey)).width;

      await tester.pumpWidget(_bar(onAction: () => taps++, showAction: false));
      await tester.pumpAndSettle();

      final wideWidth = tester.getSize(find.byKey(UiFloatingNavBar.pillKey)).width;

      await tester.tap(find.byType(UiFab), warnIfMissed: false);

      expect(taps, 0);
      expect(wideWidth, greaterThan(narrowWidth));
      expect(wideWidth, tester.getSize(find.byType(UiFloatingNavBar)).width);
    });

    testWidgets('при возврате showAction=true кнопка снова доступна', (tester) async {
      var taps = 0;

      await tester.pumpWidget(_bar(onAction: () => taps++, showAction: false));
      await tester.pumpAndSettle();
      await tester.pumpWidget(_bar(onAction: () => taps++));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(UiFab));

      expect(taps, 1);
    });
  });
}
