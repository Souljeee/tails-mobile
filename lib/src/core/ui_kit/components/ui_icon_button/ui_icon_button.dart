import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

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
    this.badgeCount = 0,
    super.key,
  });

  final IconData icon;

  /// Подпись для скринридера.
  final String semanticLabel;
  final VoidCallback? onPressed;
  final UiIconButtonVariant variant;

  /// Число в бейдже в правом верхнем углу; при `0` бейджа нет.
  final int badgeCount;

  /// Начиная с этого числа в бейдже пишется «9+».
  static const int _maxBadgeCount = 9;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final isOverlay = variant == UiIconButtonVariant.overlay;

    final button = Semantics(
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

    if (badgeCount <= 0) {
      return button;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          top: -UiSpacing.x1,
          right: -UiSpacing.x1,
          // Бейдж объясняется в подписи кнопки, поэтому для скринридера он не нужен.
          child: ExcludeSemantics(child: _CountBadge(count: badgeCount, maxCount: _maxBadgeCount)),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.maxCount});

  final int count;
  final int maxCount;

  static const double _minSize = 18;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.accent,
        borderRadius: UiRadius.fullAll,
        border: Border.all(color: palette.canvas, width: 2),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: _minSize, minHeight: _minSize),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x1),
            child: Text(
              count > maxCount ? '$maxCount+' : '$count',
              maxLines: 1,
              style: context.uiFonts.monoMeta.copyWith(
                color: palette.surface,
                fontWeight: FontWeight.w500,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
