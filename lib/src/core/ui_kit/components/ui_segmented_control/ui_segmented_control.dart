import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Вариант сегмент-контрола.
class UiSegmentedOption<T> {
  const UiSegmentedOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Сегмент-контрол Design 2.0 («Обзор / Здоровье / События»).
class UiSegmentedControl<T> extends StatelessWidget {
  const UiSegmentedControl({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<UiSegmentedOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: context.uiPalette.sunken, borderRadius: UiRadius.mdAll),
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.x1),
        child: Row(
          children: [
            for (final option in options)
              Expanded(
                child: _Segment(
                  label: option.label,
                  selected: option.value == selected,
                  onTap: () => onChanged(option.value),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: UiMotion.base,
        curve: UiMotion.curve,
        decoration: BoxDecoration(
          color: selected ? palette.surface : Colors.transparent,
          borderRadius: UiRadius.smAll,
          boxShadow: selected ? UiShadows.e1 : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: UiRadius.smAll,
            splashFactory: NoSplash.splashFactory,
            child: SizedBox(
              height: UiSizes.buttonM - UiSpacing.x2,
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.uiFonts.callout.copyWith(
                    color: selected ? palette.ink : palette.ink2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
