import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';

/// Круглая кнопка-переключатель дня: «Пн…Вс» или «1…31».
class UiDayToggle extends StatelessWidget {
  const UiDayToggle({
    required this.label,
    required this.selected,
    this.onTap,
    this.semanticsLabel,
    this.size = UiSizes.minTapTarget,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Полное название для скринридера, например «понедельник».
  final String? semanticsLabel;

  /// Диаметр кнопки; на узких экранах сетка из 7 кнопок может быть чуть меньше 44.
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      onTap: onTap,
      child: SizedBox.square(
        dimension: size,
        child: AnimatedContainer(
          duration: UiMotion.base,
          curve: UiMotion.curve,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? palette.ink : palette.surface,
            border: Border.all(color: selected ? palette.ink : palette.line),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              splashFactory: NoSplash.splashFactory,
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  style: context.uiFonts.callout.copyWith(
                    color: selected ? palette.surface : palette.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
