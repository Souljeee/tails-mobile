import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Метка питомца: цветная точка и подпись, например «● Собака».
class UiPetTag extends StatelessWidget {
  const UiPetTag({required this.label, required this.color, this.filled = true, super.key});

  final String label;

  /// Цвет точки; цвет питомца из палитры.
  final Color color;

  /// С белой подложкой (поверх фото) или без неё (на фоне экрана).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: filled ? palette.surface.withValues(alpha: 0.92) : null,
        borderRadius: UiRadius.fullAll,
      ),
      child: Padding(
        padding: filled
            ? const EdgeInsets.symmetric(horizontal: UiSpacing.x3, vertical: UiSpacing.x1 + 2)
            : EdgeInsets.zero,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: UiSpacing.x2),
            ),
            const SizedBox(width: UiSpacing.x2 - 2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.uiFonts.footnote.copyWith(
                  color: filled ? palette.ink : palette.ink2,
                  fontWeight: filled ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
