import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Пустое состояние или ошибка: иллюстрация, заголовок, пояснение и необязательное действие.
class UiEmptyState extends StatelessWidget {
  const UiEmptyState({
    required this.title,
    this.message,
    this.illustration,
    this.actionLabel,
    this.onAction,
    super.key,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel и onAction задаются вместе',
       );

  final String title;
  final String? message;

  /// Иллюстрация 150 pt, например `SvgPicture.asset(...)`.
  final Widget? illustration;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x8, vertical: UiSpacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null) ...[
              SizedBox.square(dimension: 150, child: illustration),
              const SizedBox(height: UiSpacing.x4),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: fonts.displayS.copyWith(color: palette.ink),
            ),
            if (message != null) ...[
              const SizedBox(height: UiSpacing.x2),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: fonts.body.copyWith(color: palette.ink2),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: UiSpacing.x5),
              UiButton.main(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
