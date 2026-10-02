import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Обёртка поля формы Design 2.0: подпись над полем и вспомогательный текст под ним.
class UiFormField extends StatelessWidget {
  const UiFormField({required this.child, this.label, this.helperText, this.errorText, super.key});

  final Widget child;

  /// Подпись над полем.
  final String? label;

  /// Подсказка под полем, например «Не знаете точно — укажите примерную дату».
  final String? helperText;

  /// Текст ошибки под полем. Если задан, заменяет [helperText].
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: fonts.callout.copyWith(color: palette.ink2)),
          const SizedBox(height: UiSpacing.x2),
        ],
        child,
        if (errorText != null) ...[
          const SizedBox(height: UiSpacing.x2),
          Text(errorText!, style: fonts.footnote.copyWith(color: palette.danger)),
        ] else if (helperText != null) ...[
          const SizedBox(height: UiSpacing.x2),
          Text(helperText!, style: fonts.footnote.copyWith(color: palette.ink3)),
        ],
      ],
    );
  }
}
