import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';

enum UiIconButtonVariant {
  /// Белая кнопка с границей — на фоне экрана.
  surface,

  /// Полупрозрачная белая кнопка — поверх фото.
  overlay,
}

/// Круглая иконка-кнопка 44×44 pt.
class UiIconButton extends StatelessWidget {
  const UiIconButton({
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.variant = UiIconButtonVariant.surface,
    super.key,
  });

  final IconData icon;

  /// Подпись для скринридера.
  final String semanticLabel;
  final VoidCallback? onPressed;
  final UiIconButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final isOverlay = variant == UiIconButtonVariant.overlay;

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: UiSizes.minTapTarget,
        child: Material(
          color: isOverlay ? palette.surface.withValues(alpha: 0.9) : palette.surface,
          shape: CircleBorder(side: isOverlay ? BorderSide.none : BorderSide(color: palette.line)),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            splashFactory: NoSplash.splashFactory,
            child: Center(child: Icon(icon, size: 22, color: palette.ink)),
          ),
        ),
      ),
    );
  }
}
