import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_text_link/ui_text_link.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

/// Заголовок секции: моноширинная подпись капсом и необязательная ссылка справа.
class UiSectionHeader extends StatelessWidget {
  const UiSectionHeader({required this.title, this.actionLabel, this.onActionTap, super.key});

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              style: context.uiFonts.monoEyebrow.copyWith(color: context.uiPalette.ink2),
            ),
          ),
        ),
        if (actionLabel != null) UiTextLink(label: actionLabel!, onTap: onActionTap),
      ],
    );
  }
}
