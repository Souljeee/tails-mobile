import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Раскрывающаяся карточка: заголовок, значение справа и содержимое под ним.
///
/// Содержимое занимает всю ширину карточки и само отвечает за отступы и разделители.
class UiExpandableCard extends StatelessWidget {
  const UiExpandableCard({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.value,
    this.leading,
    super.key,
  });

  final String title;

  /// Виджет слева от заголовка, например `UiIconBadge`.
  final Widget? leading;

  /// Краткое значение справа в свёрнутом виде, например «Никогда».
  final String? value;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return UiCard(
      borderRadius: UiRadius.mdAll,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: expanded,
            child: InkWell(
              onTap: onToggle,
              borderRadius: UiRadius.mdAll,
              splashFactory: NoSplash.splashFactory,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: UiSizes.buttonL),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4),
                  child: Row(
                    children: [
                      if (leading != null) ...[leading!, const SizedBox(width: UiSpacing.x3)],
                      Expanded(
                        child: Text(title, style: fonts.callout.copyWith(color: palette.ink)),
                      ),
                      if (value != null && !expanded) ...[
                        Flexible(
                          child: Text(
                            value!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: fonts.callout.copyWith(color: palette.ink3),
                          ),
                        ),
                        const SizedBox(width: UiSpacing.x2),
                      ],
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: UiMotion.base,
                        child: Icon(Icons.keyboard_arrow_down_rounded, color: palette.ink3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: UiMotion.base,
            curve: UiMotion.curve,
            alignment: Alignment.topCenter,
            child: expanded ? child : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
