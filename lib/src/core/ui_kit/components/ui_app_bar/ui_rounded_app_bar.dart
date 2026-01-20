import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class UiRoundedToolbar extends StatelessWidget {
  final String title;
  final VoidCallback onLeadingTap;
  final double borderRadius;
  final Color backgroundColor;
  final bool showBackButton;

  const UiRoundedToolbar({
    required this.title,
    required this.onLeadingTap,
    required this.borderRadius,
    required this.backgroundColor,
    this.showBackButton = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      child: AppBar(
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: backgroundColor,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20, bottom: 16),
            child: Text(
              title,
              style: context.uiFonts.header32Semibold.copyWith(color: context.uiColors.black100),
            ),
          ),
        ),
        leading:
            showBackButton
                ? IconButton(
                  padding: const EdgeInsets.only(left: 12),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: onLeadingTap,
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 28,
                    color: context.uiColors.black50,
                  ),
                )
                : null,
      ),
    );
  }
}
