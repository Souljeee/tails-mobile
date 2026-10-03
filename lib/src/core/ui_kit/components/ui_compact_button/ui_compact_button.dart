import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Небольшая белая кнопка с обводкой, по ширине содержимого: «Прикрепить скриншот»,
/// «Открыть настройки». В отличие от `UiButton` не растягивается на всю ширину.
class UiCompactButton extends StatelessWidget {
  const UiCompactButton({required this.label, required this.onPressed, this.icon, super.key});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final enabled = onPressed != null;
    final color = enabled ? palette.ink : palette.ink3;

    return Semantics(
      button: true,
      enabled: enabled,
      excludeSemantics: true,
      label: label,
      onTap: onPressed,
      child: Material(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: UiRadius.mdAll,
          side: BorderSide(color: palette.controlLine),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: UiRadius.mdAll,
          splashFactory: NoSplash.splashFactory,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: UiSizes.buttonM),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: color),
                    const SizedBox(width: UiSpacing.x2),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: context.uiFonts.callout.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
