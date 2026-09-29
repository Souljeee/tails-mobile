import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_radio/ui_radio.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Карточка выбора с иконкой, подписью и радио-индикатором («Кошка / Собака», «Мальчик / Девочка»).
class UiSelectableCard extends StatelessWidget {
  const UiSelectableCard({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: AnimatedContainer(
        duration: UiMotion.base,
        curve: UiMotion.curve,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: UiRadius.mdAll,
          border: Border.all(color: selected ? palette.ink : palette.line, width: selected ? 2 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: UiRadius.mdAll,
            splashFactory: NoSplash.splashFactory,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: UiSizes.buttonL),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 22, color: palette.ink),
                      const SizedBox(width: UiSpacing.x3),
                    ],
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.uiFonts.bodyBold.copyWith(color: palette.ink),
                      ),
                    ),
                    const SizedBox(width: UiSpacing.x2),
                    UiRadio(isSelected: selected),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
