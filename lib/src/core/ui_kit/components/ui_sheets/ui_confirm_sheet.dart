import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Шторка подтверждения: заголовок, пояснение и две кнопки друг под другом —
/// «подтвердить» (спокойная, в тоне акцента или опасности) и «Отмена».
///
/// Возвращает `true`, только если пользователь нажал кнопку подтверждения. Если
/// [destructive], кнопка подтверждения красная, иначе в цвете акцента. [highlight] — фрагмент
/// [message] (например, номер телефона), который показывается моноширинным шрифтом.
Future<bool> showUiConfirmSheet({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  String? highlight,
  bool destructive = false,
}) async {
  final confirmed = await showUiBottomSheet<bool>(
    context: context,
    name: 'confirm',
    builder: (sheetContext) => _ConfirmSheet(
      title: title,
      message: message,
      highlight: highlight,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      destructive: destructive,
    ),
  );

  return confirmed ?? false;
}

class _ConfirmSheet extends StatelessWidget {
  const _ConfirmSheet({
    required this.title,
    required this.message,
    required this.highlight,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.destructive,
  });

  final String title;
  final String message;
  final String? highlight;
  final String confirmLabel;
  final String cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final bodyStyle = fonts.body.copyWith(color: palette.ink2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: fonts.displayS.copyWith(color: palette.ink)),
        ),
        const SizedBox(height: UiSpacing.x2),
        Text.rich(TextSpan(style: bodyStyle, children: _messageSpans(fonts.monoDigits.copyWith(color: palette.ink)))),
        const SizedBox(height: UiSpacing.x5),
        UiButton.main(
          label: confirmLabel,
          staticFillColor: destructive ? palette.dangerTint : palette.accentTint,
          staticItemColor: destructive ? palette.danger : palette.accent,
          pressedFillColor: destructive ? palette.dangerTint : palette.accentTint,
          pressedItemColor: destructive ? palette.danger : palette.accent,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: UiSpacing.x3),
        UiButton.secondary(
          label: cancelLabel,
          staticFillColor: palette.surface,
          staticItemColor: palette.ink,
          defaultBorderColor: palette.line,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  List<InlineSpan> _messageSpans(TextStyle monoStyle) {
    final part = highlight;

    if (part == null || part.isEmpty || !message.contains(part)) {
      return [TextSpan(text: message)];
    }

    final index = message.indexOf(part);

    return [
      TextSpan(text: message.substring(0, index)),
      TextSpan(
        text: part,
        style: monoStyle.copyWith(fontSize: 15),
      ),
      TextSpan(text: message.substring(index + part.length)),
    ];
  }
}
