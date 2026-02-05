import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class UiBaseToolbar extends StatelessWidget {
  final String title;
  final VoidCallback onLeadingTap;
  final bool showBackButton;
  final List<Widget> actions;

  const UiBaseToolbar({
    required this.title,
    required this.onLeadingTap,
    this.showBackButton = false,
    this.actions = const [],
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      actionsPadding: const EdgeInsets.only(right: 20),
      actions: actions,
      title: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Text(
          title,
          style: context.uiFonts.header32Semibold.copyWith(
            color: context.uiColors.black100,
          ),
        ),
      ),
      leading: showBackButton
          ? IconButton(
              padding: const EdgeInsets.only(left: 12),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: onLeadingTap,
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 24,
                color: context.uiColors.black50,
              ),
            )
          : null,
    );
  }
}
