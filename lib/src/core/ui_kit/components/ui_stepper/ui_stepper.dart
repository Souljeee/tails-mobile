import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Счётчик в таблетке «− значение +» с границами [min]..[max].
class UiStepper extends StatelessWidget {
  const UiStepper({
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.decrementLabel,
    this.incrementLabel,
    super.key,
  });

  /// Минимальная ширина значения: число не «пляшет» при смене разрядности.
  static const double valueWidth = 32;

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  /// Подписи кнопок для скринридера.
  final String? decrementLabel;
  final String? incrementLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(color: palette.sunken, borderRadius: UiRadius.fullAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            label: decrementLabel,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: valueWidth),
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: context.uiFonts.bodyBold.copyWith(color: palette.ink),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            label: incrementLabel,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap, this.label});

  final IconData icon;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: UiRadius.fullAll,
        splashFactory: NoSplash.splashFactory,
        child: SizedBox.square(
          dimension: UiSizes.minTapTarget,
          child: Padding(
            padding: const EdgeInsets.all(UiSpacing.x2),
            child: Icon(icon, color: enabled ? palette.ink : palette.ink3),
          ),
        ),
      ),
    );
  }
}
