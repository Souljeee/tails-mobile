import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Таблетка с обратным отсчётом `м:сс` — «повторить можно через…».
class UiCountdownBadge extends StatelessWidget {
  const UiCountdownBadge({required this.seconds, super.key});

  final int seconds;

  static String format(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;

    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: UiRadius.fullAll,
        border: Border.all(color: palette.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4, vertical: UiSpacing.x3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, color: palette.accent, size: 24),
            const SizedBox(width: UiSpacing.x3),
            Text(format(seconds), style: context.uiFonts.monoDigits.copyWith(color: palette.ink)),
          ],
        ),
      ),
    );
  }
}
