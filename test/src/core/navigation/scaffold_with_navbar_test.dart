import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/navigation/scaffold_with_navbar.dart';
import 'package:tails_mobile/src/core/navigation/shell_actions.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_bar/ui_fab.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_bar/ui_floating_nav_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';

class _TabScreen extends StatefulWidget {
  const _TabScreen({required this.tab, required this.onAction});

  final ShellTab tab;
  final VoidCallback onAction;

  @override
  State<_TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<_TabScreen> with ShellActionMixin<_TabScreen> {
  @override
  ShellTab get shellTab => widget.tab;

  @override
  void onShellAction() => widget.onAction();

  @override
  Widget build(BuildContext context) => Text('screen-${widget.tab.name}');
}

GoRouter _router(List<String> actions) => GoRouter(
  initialLocation: '/pets',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => ScaffoldWithNavBar(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pets',
              builder: (_, _) =>
                  _TabScreen(tab: ShellTab.pets, onAction: () => actions.add('pets')),
              routes: [GoRoute(path: 'details', builder: (_, _) => const Text('details'))],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/schedule',
              builder: (_, _) =>
                  _TabScreen(tab: ShellTab.schedule, onAction: () => actions.add('schedule')),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/profile', builder: (_, _) => const Text('profile'))],
        ),
      ],
    ),
  ],
);

Widget _app(GoRouter router) => MaterialApp.router(
  routerConfig: router,
  theme: UiThemeData.lightTheme,
  locale: const Locale('ru'),
  localizationsDelegates: Localization.localizationDelegates,
  supportedLocales: Localization.supportedLocales,
);

void main() {
  testWidgets('«+» вызывает действие активной вкладки', (tester) async {
    final actions = <String>[];
    await tester.pumpWidget(_app(_router(actions)));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(UiFab));
    expect(actions, ['pets']);

    await tester.tap(find.text('Календарь'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(UiFab));

    expect(actions, ['pets', 'schedule']);
  });

  testWidgets('на вкладке «Профиль» «+» скрыт, пилюля растягивается', (tester) async {
    await tester.pumpWidget(_app(_router([])));
    await tester.pumpAndSettle();

    final narrow = tester.getSize(find.byKey(UiFloatingNavBar.pillKey)).width;

    await tester.tap(find.text('Профиль'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byKey(UiFloatingNavBar.pillKey)).width, greaterThan(narrow));
  });

  testWidgets('на вложенном экране «+» скрыт, при возврате появляется', (tester) async {
    final router = _router([]);
    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();

    final narrow = tester.getSize(find.byKey(UiFloatingNavBar.pillKey)).width;

    router.go('/pets/details');
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(UiFloatingNavBar.pillKey)).width, greaterThan(narrow));

    router.go('/pets');
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(UiFloatingNavBar.pillKey)).width, narrow);
  });
}
