import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

const double _checkboxSize = 28;
const int _animationMs = 250;

class UiCheckbox extends StatelessWidget {
  final bool isChecked;
  final VoidCallback? onTap;

  const UiCheckbox({required this.isChecked, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: _animationMs),
        curve: Curves.easeInOut,
        width: _checkboxSize,
        height: _checkboxSize,
        decoration: BoxDecoration(
          color: isChecked ? context.uiColors.orangePrimary.withValues(alpha: 0.5) : Colors.transparent,
          shape: BoxShape.circle,
          border: isChecked
              ? null
              : Border.all(color: context.uiColors.black30, width: 2),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: _animationMs),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: isChecked
              ? const _CheckIcon(key: ValueKey('checked'))
              : const SizedBox.shrink(key: ValueKey('unchecked')),
        ),
      ),
    );
  }
}

class _CheckIcon extends StatelessWidget {
  const _CheckIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.check_rounded,
      size: _checkboxSize * 0.6,
      color: context.uiColors.white,
    );
  }
}
