import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';

const double _radioSize = 24;
const double _dotSize = 8;

/// Индикатор радио-кнопки: выбранный — тёмный круг с точкой, невыбранный — контур.
class UiRadio extends StatelessWidget {
  final bool isSelected;

  const UiRadio({required this.isSelected, super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Semantics(
      selected: isSelected,
      child: AnimatedContainer(
        duration: UiMotion.base,
        curve: UiMotion.curve,
        width: _radioSize,
        height: _radioSize,
        decoration: BoxDecoration(
          color: isSelected ? palette.ink : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? palette.ink : palette.controlLine, width: 2),
        ),
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1 : 0,
            duration: UiMotion.base,
            curve: UiMotion.curve,
            child: DecoratedBox(
              decoration: BoxDecoration(color: palette.surface, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: _dotSize),
            ),
          ),
        ),
      ),
    );
  }
}
