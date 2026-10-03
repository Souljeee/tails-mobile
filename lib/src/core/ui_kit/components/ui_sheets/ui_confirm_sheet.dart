import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Шторка подтверждения: иконка, заголовок, пояснение и пара кнопок «отмена / подтвердить».
///
/// Возвращает `true`, только если пользователь нажал кнопку подтверждения. Если
/// [destructive], иконка и кнопка подтверждения красные («Выйти», «Удалить»).
Future<bool> showUiConfirmSheet({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = true,
}) async {
  final confirmed = await showUiBottomSheet<bool>(
    context: context,
    builder: (sheetContext) => _ConfirmSheet(
      icon: icon,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );

  return confirmed ?? false;
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
  });

  final IconData icon;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Column(
      children: [
        UiIconBadge(
          icon: icon,
          size: 64,
          iconSize: 28,
          foregroundColor: destructive ? palette.danger : palette.accent,
          backgroundColor: destructive ? palette.dangerTint : palette.accentTint,
        ),
        const SizedBox(height: UiSpacing.x5),
        Text(
          title,
          style: fonts.displayS.copyWith(color: palette.ink),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UiSpacing.x2),
        Text(
          message,
          style: fonts.body.copyWith(color: palette.ink2),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: UiSpacing.x6),
        Row(
          children: [
            Expanded(
              child: UiButton.secondary(
                label: cancelLabel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: UiSpacing.x3),
            Expanded(
              child: UiButton.main(
                label: confirmLabel,
                staticFillColor: destructive ? palette.danger : null,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
