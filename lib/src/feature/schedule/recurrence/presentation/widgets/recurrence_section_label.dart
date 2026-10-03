import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Подпись блока настроек повторения: моно, заглавными («ДНИ НЕДЕЛИ»).
class RecurrenceSectionLabel extends StatelessWidget {
  const RecurrenceSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: UiSpacing.x1, bottom: UiSpacing.x2),
      child: Text(
        text.toUpperCase(),
        style: context.uiFonts.monoEyebrow.copyWith(color: context.uiPalette.ink2),
      ),
    );
  }
}
