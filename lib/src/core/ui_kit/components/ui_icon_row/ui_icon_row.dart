import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Строка «иконка в плитке — заголовок и подпись — действие справа».
///
/// Если задан [onTap], нажимается вся строка. Для акцентных строк вроде «Добавить дату»
/// задайте [accent].
class UiIconRow extends StatelessWidget {
  const UiIconRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accent = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Виджет справа: счётчик, шеврон.
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Акцентная строка: плитка `accentTint`, заголовок цветом `accent`.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: UiSizes.buttonL),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: UiSpacing.x2),
        child: Row(
          children: [
            UiIconBadge(
              icon: icon,
              size: 36,
              iconSize: 18,
              foregroundColor: accent ? palette.accent : palette.ink2,
              backgroundColor: accent ? palette.accentTint : palette.sunken,
            ),
            const SizedBox(width: UiSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: fonts.bodySemibold.copyWith(
                      color: accent ? palette.accent : palette.ink,
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle!, style: fonts.footnote.copyWith(color: palette.ink3)),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: UiSpacing.x3), trailing!],
          ],
        ),
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Semantics(
      button: true,
      child: InkWell(onTap: onTap, splashFactory: NoSplash.splashFactory, child: row),
    );
  }
}
