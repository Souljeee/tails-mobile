import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_compact_button/ui_compact_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Янтарная плашка: иконка, необязательный заголовок, текст и необязательная кнопка-действие,
/// например «Уведомления отключены в настройках устройства — Открыть настройки».
class UiNoticeBanner extends StatelessWidget {
  const UiNoticeBanner({
    required this.text,
    this.title,
    this.icon = Icons.warning_amber_rounded,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String text;
  final String? title;
  final IconData icon;

  /// Подпись кнопки-действия; кнопка показывается, только если задан и [onAction].
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final hasAction = actionLabel != null && onAction != null;

    return DecoratedBox(
      decoration: BoxDecoration(color: palette.amberTint, borderRadius: UiRadius.mdAll),
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.x4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 22, color: palette.amber),
            const SizedBox(width: UiSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(title!, style: fonts.bodySemibold.copyWith(color: palette.ink)),
                  Text(text, style: fonts.footnote.copyWith(color: palette.ink2)),
                  if (hasAction) ...[
                    const SizedBox(height: UiSpacing.x3),
                    UiCompactButton(label: actionLabel!, onPressed: onAction),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
