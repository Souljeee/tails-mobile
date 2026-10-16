import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_radio/ui_radio.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Строка выбора напоминания: радио, название и вторая строка с точным временем.
///
/// [onTap] `null` — вариант недоступен (время уже прошло): название и радио приглушены.
/// [semanticsLabel] заменяет озвучку строки, например «За 1 час, недоступно, время уже прошло».
class ReminderOptionRow extends StatelessWidget {
  const ReminderOptionRow({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.semanticsLabel,
    this.showChevron = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  /// Стрелка справа: строка ведёт на следующий шаг («Своё время»).
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: semanticsLabel,
      excludeSemantics: semanticsLabel != null,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: UiSizes.buttonL),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: UiSpacing.x2),
            child: Row(
              children: [
                Opacity(
                  opacity: enabled ? 1 : 0.4,
                  child: UiRadio(isSelected: selected),
                ),
                const SizedBox(width: UiSpacing.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: (selected ? fonts.bodyBold : fonts.body).copyWith(
                          color: enabled ? palette.ink : palette.ink3,
                        ),
                      ),
                      Text(subtitle, style: fonts.footnote.copyWith(color: palette.ink3)),
                    ],
                  ),
                ),
                if (showChevron) ...[
                  const SizedBox(width: UiSpacing.x2),
                  Icon(Icons.chevron_right_rounded, color: palette.ink3),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
