import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Чип выбора: фильтр по питомцу, тип события. Выбранный чип залит цветом `ink`.
class UiChip extends StatelessWidget {
  const UiChip({required this.label, required this.selected, this.onTap, this.leading, super.key});

  /// Высота чипа (с рамкой) — область нажатия 44 pt.
  static const double height = UiSizes.minTapTarget;

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Виджет слева от текста, например аватар питомца.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: UiMotion.base,
        curve: UiMotion.curve,
        decoration: BoxDecoration(
          color: selected ? palette.ink : palette.surface,
          borderRadius: UiRadius.fullAll,
          border: Border.all(color: selected ? palette.ink : palette.line),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: UiRadius.fullAll,
            splashFactory: NoSplash.splashFactory,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: UiSizes.minTapTarget - 2),
              child: Padding(
                padding: EdgeInsets.only(
                  left: leading == null ? UiSpacing.x4 : UiSpacing.x2,
                  right: UiSpacing.x4,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leading != null) ...[leading!, const SizedBox(width: UiSpacing.x2)],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.uiFonts.callout.copyWith(
                          color: selected ? palette.surface : palette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
