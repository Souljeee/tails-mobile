import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Показатель полосы: подпись и значение.
class UiStatItem {
  const UiStatItem({required this.label, required this.value});

  final String label;
  final String value;
}

/// Карточка с несколькими показателями в ряд: «Возраст | Вес | Пол».
class UiStatStrip extends StatelessWidget {
  const UiStatStrip({required this.items, super.key});

  final List<UiStatItem> items;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return UiCard(
      padding: const EdgeInsets.symmetric(vertical: UiSpacing.x3),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) VerticalDivider(width: 1, thickness: 1, color: palette.line),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        items[i].label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: fonts.monoEyebrow.copyWith(
                          color: palette.ink3,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: UiSpacing.x1),
                      Text(
                        items[i].value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: fonts.headline.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
