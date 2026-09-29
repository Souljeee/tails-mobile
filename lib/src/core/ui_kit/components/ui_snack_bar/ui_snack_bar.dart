import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

enum UiSnackBarKind { error, success, info }

/// Показывает снекбар Design 2.0 и закрывает предыдущий.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showUiSnackBar(
  BuildContext context, {
  required String message,
  UiSnackBarKind kind = UiSnackBarKind.error,
}) {
  final palette = context.uiPalette;
  final color = switch (kind) {
    UiSnackBarKind.error => palette.danger,
    UiSnackBarKind.success => palette.pine,
    UiSnackBarKind.info => palette.ink,
  };
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

  return messenger.showSnackBar(
    SnackBar(
      content: Text(message, style: context.uiFonts.callout.copyWith(color: palette.surface)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(UiSpacing.x4),
      shape: const RoundedRectangleBorder(borderRadius: UiRadius.mdAll),
    ),
  );
}
