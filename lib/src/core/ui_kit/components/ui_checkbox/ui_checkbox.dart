import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';

const double _checkboxSize = 28;

/// Круглый чекбокс выполнения: пустой контур или заливка `pine` с галочкой.
///
/// Область касания — 44×44 pt.
class UiCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback? onTap;

  const UiCheckbox({required this.isChecked, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Semantics(
      checked: isChecked,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: UiSizes.minTapTarget,
          child: Center(
            child: AnimatedContainer(
              duration: UiMotion.base,
              curve: UiMotion.curve,
              width: _checkboxSize,
              height: _checkboxSize,
              decoration: BoxDecoration(
                color: isChecked ? palette.pine : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isChecked ? palette.pine : palette.controlLine, width: 2),
              ),
              child: AnimatedSwitcher(
                duration: UiMotion.base,
                switchInCurve: Curves.easeIn,
                switchOutCurve: Curves.easeOut,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: isChecked
                    ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('checked'),
                        size: _checkboxSize * 0.6,
                        color: palette.surface,
                      )
                    : const SizedBox.shrink(key: ValueKey('unchecked')),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
