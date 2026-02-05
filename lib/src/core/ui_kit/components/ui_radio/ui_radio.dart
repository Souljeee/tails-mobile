import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

const double _radioSize = 20;

class UiRadio extends StatelessWidget {
  final bool isSelected;

  const UiRadio({
    required this.isSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return isSelected ? const _SelectedState() : const _UnselectedState();
  }
}

class _SelectedState extends StatelessWidget {
  const _SelectedState();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _radioSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.uiColors.orangePrimary,
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsetsGeometry.all(4),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.uiColors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _UnselectedState extends StatelessWidget {
  const _UnselectedState();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _radioSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.uiColors.black20,
          border: Border.all(color: context.uiColors.black30),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
