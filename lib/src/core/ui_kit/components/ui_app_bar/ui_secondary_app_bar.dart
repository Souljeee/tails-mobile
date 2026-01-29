import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_rounded_button.dart/ui_rounded_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class UiSecondaryToolbar extends StatelessWidget {
  const UiSecondaryToolbar({
    required this.title,
    required this.description,
    required this.onActionTap,
    required this.actionIcon,
    this.maxLines,
    super.key,
  });

  final String title;
  final String description;
  final int? maxLines;
  final VoidCallback onActionTap;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.uiFonts.header32Semibold,
            textAlign: TextAlign.start,
          ),
          Text(
            description,
            style: context.uiFonts.text16Regular.copyWith(
              color: context.uiColors.black50,
            ),
          ),
        ],
      ),
      titleSpacing: 20,
      actions: [
        UiRoundedButton.filled(
          onPressed: onActionTap,
          icon: actionIcon,
        ),
        const SizedBox(width: 20),
      ],
    );
  }
}
