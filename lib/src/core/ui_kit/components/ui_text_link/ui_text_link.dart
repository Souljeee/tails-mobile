import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';

/// Текстовая ссылка-действие акцентного цвета («Изменить», «Все», «Открыть»).
class UiTextLink extends StatelessWidget {
  const UiTextLink({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: UiSizes.minTapTarget,
            minHeight: UiSizes.minTapTarget,
          ),
          child: Align(
            widthFactor: 1,
            alignment: Alignment.centerRight,
            child: Text(
              label,
              style: context.uiFonts.callout.copyWith(
                color: context.uiPalette.accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
