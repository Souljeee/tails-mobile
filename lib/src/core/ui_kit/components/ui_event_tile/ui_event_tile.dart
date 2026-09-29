import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_checkbox/ui_checkbox.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Карточка события: цветная полоса питомца, аватар, название, тип и чекбокс выполнения.
class UiEventTile extends StatelessWidget {
  const UiEventTile({
    required this.title,
    required this.subtitle,
    required this.stripeColor,
    required this.leading,
    required this.isDone,
    required this.onToggle,
    this.typeIcon,
    super.key,
  });

  final String title;

  /// Например «Лекарства · Мистерио».
  final String subtitle;

  /// Цвет питомца.
  final Color stripeColor;

  /// Аватар питомца.
  final Widget leading;
  final bool isDone;
  final VoidCallback? onToggle;

  /// Иконка типа события перед [subtitle].
  final IconData? typeIcon;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return AnimatedContainer(
      duration: UiMotion.base,
      curve: UiMotion.curve,
      decoration: BoxDecoration(
        color: isDone ? palette.sunken : palette.surface,
        borderRadius: UiRadius.mdAll,
        boxShadow: isDone ? null : UiShadows.e1,
      ),
      child: ClipRRect(
        borderRadius: UiRadius.mdAll,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: UiSpacing.x1,
                child: ColoredBox(color: stripeColor),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    UiSpacing.x3,
                    UiSpacing.x3,
                    UiSpacing.x1,
                    UiSpacing.x3,
                  ),
                  child: Row(
                    children: [
                      leading,
                      const SizedBox(width: UiSpacing.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: UiMotion.base,
                              style: fonts.bodyBold.copyWith(
                                color: isDone ? palette.ink3 : palette.ink,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                              child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                if (typeIcon != null) ...[
                                  Icon(typeIcon, size: 14, color: palette.ink3),
                                  const SizedBox(width: UiSpacing.x1),
                                ],
                                Flexible(
                                  child: Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: fonts.footnote.copyWith(color: palette.ink2),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      UiCheckbox(isChecked: isDone, onTap: onToggle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
