import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_app_bar/ui_base_app_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_app_bar/ui_rounded_app_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_app_bar/ui_secondary_app_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_app_bar/ui_segmented_app_bar.dart';

/// Represents different types of app bars in the UI
enum UiAppBarType { baseToolBar, segmentedToolBar, secondaryToolBar, roundedToolBar }

class UiAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The type of app bar to be displayed
  final UiAppBarType type;

  /// Title for base and secondary app bars
  final String title;

  /// Tabs for segmented app bar
  final List<UiTabItemData> tabs;

  /// Initial tab index for segmented app bar
  final int initialTabIndex;

  /// Description for secondary app bar
  final String description;

  /// Action callback for secondary app bar
  final VoidCallback onActionTap;

  /// Leading tap callback for base app bar
  final VoidCallback onLeadingTap;

  /// Show back button for base app bar
  final bool showBackButton;

  /// Action SVG path for secondary app bar
  final IconData actionIcon;

  /// Background color for segmented app bar
  final Color backgroundColor;

  final double borderRadius;

  /// Actions for base app bar
  final List<Widget> actions;

  const UiAppBar.baseToolBar({
    required this.title,
    this.onLeadingTap = _noop,
    this.showBackButton = false,
    this.actions = const [],
    super.key,
  })  : type = UiAppBarType.baseToolBar,
        tabs = const [],
        description = '',
        initialTabIndex = 0,
        onActionTap = _noop,
        backgroundColor = Colors.transparent,
        actionIcon = Icons.search,
        borderRadius = 0.0;

  const UiAppBar.segmentedToolBar({
    required this.tabs,
    required this.backgroundColor,
    this.initialTabIndex = 0,
    this.showBackButton = false,
    this.actions = const [],
    super.key,
  })  : type = UiAppBarType.segmentedToolBar,
        title = '',
        description = '',
        onActionTap = _noop,
        onLeadingTap = _noop,
        actionIcon = Icons.search,
        borderRadius = 0.0;

  const UiAppBar.secondaryToolBar({
    required this.title,
    required this.description,
    required this.actionIcon,
    required this.onActionTap,
    this.showBackButton = false,
    this.actions = const [],
    super.key,
  })  : type = UiAppBarType.secondaryToolBar,
        tabs = const [],
        initialTabIndex = 0,
        backgroundColor = Colors.transparent,
        onLeadingTap = _noop,
        borderRadius = 0.0;

  const UiAppBar.roundedToolBar({
    required this.title,
    required this.borderRadius,
    required this.backgroundColor,
    this.showBackButton = false,
    this.actions = const [],
    super.key,
  })  : type = UiAppBarType.roundedToolBar,
        tabs = const [],
        description = '',
        initialTabIndex = 0,
        onLeadingTap = _noop,
        onActionTap = _noop,
        actionIcon = Icons.search;

  /// Empty function placeholder
  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      UiAppBarType.baseToolBar => UiBaseToolbar(
          title: title,
          onLeadingTap: onLeadingTap,
          showBackButton: showBackButton,
          actions: actions,
        ),
      UiAppBarType.segmentedToolBar => UiSegmentedToolbar(
          tabs: tabs,
          backgroundColor: backgroundColor,
          showBackButton: showBackButton,
        ),
      UiAppBarType.secondaryToolBar => UiSecondaryToolbar(
          title: title,
          description: description,
          onActionTap: onActionTap,
          actionIcon: actionIcon,
        ),
      UiAppBarType.roundedToolBar => UiRoundedToolbar(
          title: title,
          onLeadingTap: onLeadingTap,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor,
          showBackButton: showBackButton,
        ),
    };
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
