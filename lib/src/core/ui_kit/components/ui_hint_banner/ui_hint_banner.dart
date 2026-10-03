import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Плашка-подсказка: «в коротких месяцах — в последний день», «29 февраля…».
class UiHintBanner extends StatelessWidget {
  const UiHintBanner({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(color: palette.amberTint, borderRadius: UiRadius.mdAll),
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.x3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 20, color: palette.amber),
            const SizedBox(width: UiSpacing.x2),
            Expanded(
              child: Text(text, style: context.uiFonts.footnote.copyWith(color: palette.ink)),
            ),
          ],
        ),
      ),
    );
  }
}
