import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/navigation/shell_actions.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_bar/ui_fab.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_bar/ui_floating_nav_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

/// Оболочка приложения: контент ветки и плавающая навигация с кнопкой «+».
///
/// На корневых экранах вкладок показаны «пилюля» и «+». На вложенных экранах
/// (например, карточке питомца) «+» скрывается, а «пилюля» растягивается на всю ширину.
class ScaffoldWithNavBar extends StatefulWidget {
  const ScaffoldWithNavBar({required this.navigationShell, Key? key})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// Контейнер навигации веток.
  final StatefulNavigationShell navigationShell;

  /// Корневые маршруты вкладок; на них показывается кнопка «+».
  static List<String> get rootLocations => [
    const PetsRoute().location,
    const ScheduleRoute().location,
    const ProfileRoute().location,
  ];

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  final ShellActionsController _actions = ShellActionsController();

  static const double _bottomGap = UiSpacing.x4;

  void _onTap(int index) {
    // При повторном нажатии на активную вкладку возвращаемся на её корневой экран.
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  void _onActionPressed() {
    final tab = ShellTab.values[widget.navigationShell.currentIndex];

    _actions.actionFor(tab)?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final location = GoRouterState.of(context).uri.path;
    final isRoot = ScaffoldWithNavBar.rootLocations.contains(location);
    final currentTab = ShellTab.values[widget.navigationShell.currentIndex];
    final canAdd = currentTab != ShellTab.profile;
    final inset = UiFloatingNavBar.height + _bottomGap * 2 + safeBottom;

    return ShellScope(
      controller: _actions,
      bottomInset: inset,
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Positioned.fill(child: widget.navigationShell),
            Positioned(
              left: UiSpacing.x4,
              right: UiSpacing.x4,
              bottom: _bottomGap + safeBottom,
              child: UiFloatingNavBar(
                items: [
                  UiNavBarItem(
                    icon: Icons.pets_outlined,
                    activeIcon: Icons.pets,
                    label: l10n.navPets,
                  ),
                  UiNavBarItem(
                    icon: Icons.calendar_month_outlined,
                    activeIcon: Icons.calendar_month,
                    label: l10n.navCalendar,
                  ),
                  UiNavBarItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: l10n.navProfile,
                  ),
                ],
                currentIndex: widget.navigationShell.currentIndex,
                onTap: _onTap,
                showAction: isRoot && canAdd,
                action: UiFab(
                  onPressed: _onActionPressed,
                  semanticLabel: currentTab == ShellTab.pets ? l10n.navAddPet : l10n.navAddEvent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
