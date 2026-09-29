import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Строка с заголовком, пояснением и переключателем, например «Стерилизована».
class UiSwitchRow extends StatelessWidget {
  const UiSwitchRow({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return UiCard(
      borderRadius: UiRadius.mdAll,
      showBorder: true,
      showShadow: false,
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4, vertical: UiSpacing.x3),
      child: MergeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: fonts.callout.copyWith(color: palette.ink)),
                  if (subtitle != null)
                    Text(subtitle!, style: fonts.footnote.copyWith(color: palette.ink3)),
                ],
              ),
            ),
            const SizedBox(width: UiSpacing.x3),
            Switch(
              value: value,
              onChanged: onChanged,
              thumbColor: WidgetStatePropertyAll(palette.surface),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? palette.accent : palette.sunken,
              ),
              trackOutlineColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? palette.accent : palette.controlLine,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
