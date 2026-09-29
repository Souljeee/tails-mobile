import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';

/// Круглая акцентная кнопка действия («+») рядом с нижней навигацией.
class UiFab extends StatelessWidget {
  const UiFab({
    required this.onPressed,
    required this.semanticLabel,
    this.icon = Icons.add,
    super.key,
  });

  static const double size = 64;

  final VoidCallback? onPressed;

  /// Подпись для скринридера.
  final String semanticLabel;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.accent,
          shape: BoxShape.circle,
          boxShadow: UiShadows.e2,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            splashFactory: NoSplash.splashFactory,
            highlightColor: palette.accentPressed,
            child: SizedBox.square(
              dimension: size,
              child: Icon(icon, size: 28, color: palette.surface),
            ),
          ),
        ),
      ),
    );
  }
}
