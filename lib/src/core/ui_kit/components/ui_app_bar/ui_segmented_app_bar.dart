import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class UiTabItemData {
  final String label;
  final bool hasBadge;

  const UiTabItemData({required this.label, this.hasBadge = false});
}

class UiSegmentedToolbar extends StatelessWidget {
  final List<UiTabItemData> tabs;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;
  final Color? badgeColor;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;

  UiSegmentedToolbar({
    required this.tabs,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
    this.badgeColor,
    this.labelStyle,
    this.unselectedLabelStyle,
    super.key,
  }) : assert(tabs.isNotEmpty, 'Tabs cannot be empty');

  @override
  Widget build(BuildContext context) {
    final defaultBadgeColor = context.uiColors.blue100;
    final actualBadgeColor = badgeColor ?? defaultBadgeColor;

    return AppBar(
      elevation: 0,
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              padding: const EdgeInsets.only(left: 12),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: onBackPressed,
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: context.uiColors.black50,
                size: 28,
              ),
            )
          : null,
      surfaceTintColor: Colors.transparent,
      backgroundColor: backgroundColor ?? Colors.transparent,
      bottom: TabBar(
        padding: const EdgeInsets.only(left: 6),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: tabs
            .map(
              (tab) => Tab(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(tab.label),
                    if (tab.hasBadge)
                      Positioned(
                        right: -10,
                        top: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: actualBadgeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            )
            .toList(),
        labelColor: labelColor ?? context.uiColors.black100,
        labelStyle: labelStyle ?? context.uiFonts.header32Semibold,
        unselectedLabelColor: unselectedLabelColor ?? context.uiColors.black40,
        unselectedLabelStyle: unselectedLabelStyle,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(width: 2, color: indicatorColor ?? context.uiColors.black100),
        ),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => states.contains(WidgetState.focused) ? null : Colors.transparent,
        ),
      ),
    );
  }
}
