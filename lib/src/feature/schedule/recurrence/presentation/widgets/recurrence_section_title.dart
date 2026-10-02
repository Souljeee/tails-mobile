import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Подпись над блоком настроек повторения.
class RecurrenceSectionTitle extends StatelessWidget {
  const RecurrenceSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.x2),
      child: Text(text, style: context.uiFonts.callout.copyWith(color: context.uiPalette.ink2)),
    );
  }
}
