import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Вкладка нижней навигации.
class UiNavBarItem {
  const UiNavBarItem({required this.icon, required this.label, this.activeIcon});

  final IconData icon;

  /// Иконка активной вкладки; по умолчанию как [icon].
  final IconData? activeIcon;
  final String label;
}

/// Плавающая «пилюля» нижней навигации Design 2.0 с необязательной кнопкой действия справа.
///
/// Когда [showAction] становится `false`, кнопка [action] плавно сворачивается, а пилюля
/// растягивается на всю ширину; при `true` анимация идёт в обратную сторону.
/// Отступы от краёв экрана и SafeArea задаёт вызывающий код.
class UiFloatingNavBar extends StatelessWidget {
  const UiFloatingNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.action,
    this.showAction = true,
    super.key,
  });

  /// Ключ пилюли, нужен тестам для проверки её ширины.
  static const pillKey = ValueKey<String>('ui_floating_nav_pill');

  /// Высота панели.
  static const double height = 64;

  final List<UiNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Кнопка действия справа от пилюли, обычно `UiFab`.
  final Widget? action;
  final bool showAction;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context) ? Duration.zero : UiMotion.large;

    return Row(
      children: [
        Expanded(
          child: _NavPill(key: pillKey, items: items, currentIndex: currentIndex, onTap: onTap),
        ),
        if (action != null)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(end: showAction ? 1 : 0),
            duration: duration,
            curve: UiMotion.curve,
            builder: (context, factor, child) => ClipRect(
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: factor,
                child: Opacity(opacity: factor, child: child),
              ),
            ),
            child: ExcludeSemantics(
              excluding: !showAction,
              child: IgnorePointer(
                ignoring: !showAction,
                child: Padding(
                  padding: const EdgeInsets.only(left: UiSpacing.x3),
                  child: action,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({required this.items, required this.currentIndex, required this.onTap, super.key});

  final List<UiNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.uiPalette.surface,
        borderRadius: UiRadius.fullAll,
        boxShadow: UiShadows.e2,
      ),
      child: SizedBox(
        height: UiFloatingNavBar.height,
        child: Padding(
          padding: const EdgeInsets.all(UiSpacing.x2),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.item, required this.selected, required this.onTap});

  final UiNavBarItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final color = selected ? palette.accent : palette.ink2;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: UiRadius.fullAll,
          splashFactory: NoSplash.splashFactory,
          child: AnimatedContainer(
            duration: UiMotion.base,
            curve: UiMotion.curve,
            decoration: BoxDecoration(
              color: selected ? palette.accentTint : Colors.transparent,
              borderRadius: UiRadius.fullAll,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(selected ? item.activeIcon ?? item.icon : item.icon, size: 22, color: color),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // Подпись в панели фиксированной высоты: крупный шрифт ограничиваем.
                  textScaler: MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.3),
                  style: context.uiFonts.footnote.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
