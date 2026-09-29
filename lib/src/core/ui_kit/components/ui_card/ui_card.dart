import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Карточка Design 2.0: белая поверхность со скруглением и лёгкой тенью.
class UiCard extends StatelessWidget {
  const UiCard({
    required this.child,
    this.padding = const EdgeInsets.all(UiSpacing.x4),
    this.borderRadius = UiRadius.lgAll,
    this.onTap,
    this.color,
    this.showBorder = false,
    this.showShadow = true,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  /// Если задан, вся карточка нажимается.
  final VoidCallback? onTap;

  /// Цвет фона; по умолчанию `surface`.
  final Color? color;

  /// Рисовать ли тонкую границу `line`.
  final bool showBorder;

  /// Рисовать ли тень e1.
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final content = Padding(padding: padding, child: child);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? palette.surface,
        borderRadius: borderRadius,
        border: showBorder ? Border.all(color: palette.line) : null,
        boxShadow: showShadow ? UiShadows.e1 : null,
      ),
      child: onTap == null
          ? content
          : Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                splashFactory: NoSplash.splashFactory,
                highlightColor: palette.sunken.withValues(alpha: 0.6),
                child: content,
              ),
            ),
    );
  }
}
