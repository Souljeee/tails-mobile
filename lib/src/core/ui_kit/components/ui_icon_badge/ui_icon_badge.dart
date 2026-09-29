import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';

/// Скруглённый квадрат с иконкой на тонированном фоне.
///
/// По умолчанию — иконка `accent` на `accentTint`.
class UiIconBadge extends StatelessWidget {
  const UiIconBadge({
    required this.icon,
    this.size = 40,
    this.iconSize = 20,
    this.foregroundColor,
    this.backgroundColor,
    super.key,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? palette.accentTint,
        borderRadius: UiRadius.smAll,
      ),
      child: SizedBox.square(
        dimension: size,
        child: Icon(icon, size: iconSize, color: foregroundColor ?? palette.accent),
      ),
    );
  }
}
