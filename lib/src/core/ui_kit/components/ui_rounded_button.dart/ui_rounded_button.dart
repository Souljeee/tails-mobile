import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

enum UiRoundedButtonType { filled, outlined, iconOnly }

class UiRoundedButton extends StatelessWidget {

  final VoidCallback? onPressed;

  final UiRoundedButtonType _type;

  final double size;

  final Color? staticFillColor,
      staticItemColor,
      pressedFillColor,
      pressedItemColor,
      disabledItemColor,
      disabledFillColor,
      defaultBorderColor,
      pressedBorderColor,
      disabledBorderColor,
      iconColor;

  final IconData? icon;

  const UiRoundedButton.filled({
    super.key,
    this.onPressed,
    this.staticFillColor,
    this.staticItemColor,
    this.pressedFillColor,
    this.pressedItemColor,
    this.disabledFillColor,
    this.disabledItemColor,
    this.defaultBorderColor,
    this.pressedBorderColor,
    this.disabledBorderColor,
    this.size = 60,
    this.iconColor,
    this.icon,
  }) : _type = UiRoundedButtonType.filled;

  const UiRoundedButton.outlined({
    super.key,
    this.onPressed,
    this.staticFillColor,
    this.staticItemColor,
    this.pressedFillColor,
    this.pressedItemColor,
    this.disabledFillColor,
    this.disabledItemColor,
    this.pressedBorderColor,
    this.disabledBorderColor,
    this.defaultBorderColor,
    this.size = 60,
    this.iconColor,
    this.icon,
  }) : _type = UiRoundedButtonType.outlined;

  const UiRoundedButton.iconOnly({
    super.key,
    this.onPressed,
    this.staticFillColor,
    this.staticItemColor,
    this.pressedFillColor,
    this.pressedItemColor,
    this.disabledFillColor,
    this.disabledItemColor,
    this.pressedBorderColor,
    this.disabledBorderColor,
    this.defaultBorderColor,
    this.size = 60,
    this.iconColor,
    this.icon,
  }) : _type = UiRoundedButtonType.iconOnly;

  @override
  Widget build(BuildContext context) {
    final colorScheme = _getColorScheme(context);

    return SizedBox(
      height: size,
      width: size,
      child: IconButton(
        style: _createButtonStyle(context),
        onPressed: onPressed,
        icon: Icon(
          icon ?? Icons.arrow_forward_ios,
          color:
              onPressed == null
                  ? colorScheme.disabledItem
                  : colorScheme.staticItem,
        ),
      ),
    );
  }

  _RoundedButtonColorScheme _getColorScheme(BuildContext context) {
    final colors = context.uiColors;

    const transparent = Colors.transparent;

    switch (_type) {
      case UiRoundedButtonType.filled:
        return _RoundedButtonColorScheme(
          staticFill: staticFillColor ?? colors.blue100,
          staticItem: staticItemColor ?? colors.white,
          pressedFill: pressedFillColor ?? colors.blueHover,
          pressedItem: pressedItemColor ?? colors.white,
          disabledFill:
              disabledFillColor ?? colors.blue100.withValues(alpha: 0.3),
          disabledItem: disabledItemColor ?? colors.white,
          defaultBorder: defaultBorderColor ?? transparent,
          pressedBorder: pressedBorderColor ?? transparent,
          disabledBorder: disabledBorderColor ?? transparent,
        );

      case UiRoundedButtonType.outlined:
        return _RoundedButtonColorScheme(
          staticFill: staticFillColor ?? transparent,
          staticItem: staticItemColor ?? colors.blue100,
          pressedFill: pressedFillColor ?? transparent,
          pressedItem: pressedItemColor ?? colors.blue100,
          disabledFill: disabledFillColor ?? transparent,
          disabledItem:
              disabledItemColor ?? colors.blue100.withValues(alpha: 0.6),
          defaultBorder: defaultBorderColor ?? colors.blueHover,
          pressedBorder: pressedBorderColor ?? colors.blueHover,
          disabledBorder: disabledBorderColor ?? colors.blueStroke,
        );

      case UiRoundedButtonType.iconOnly:
        return _RoundedButtonColorScheme(
          staticFill: staticFillColor ?? transparent,
          staticItem: staticItemColor ?? colors.blue100,
          pressedFill: pressedFillColor ?? transparent,
          pressedItem: pressedItemColor ?? colors.blue100,
          disabledFill: disabledFillColor ?? transparent,
          disabledItem:
              disabledItemColor ?? colors.blue100.withValues(alpha: 0.6),
          defaultBorder: defaultBorderColor ?? transparent,
          pressedBorder: pressedBorderColor ?? transparent,
          disabledBorder: disabledBorderColor ?? transparent,
        );
    }
  }

  ButtonStyle _createButtonStyle(BuildContext context) {
    final colorScheme = _getColorScheme(context);

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.disabledFill;
        }
        return colorScheme.staticFill;
      }),

      tapTargetSize: MaterialTapTargetSize.shrinkWrap,

      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.pressedFill;
        }
        return Colors.transparent;
      }),

      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return BorderSide(color: colorScheme.pressedBorder, width: 1.5);
        }
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: colorScheme.disabledBorder, width: 1.5);
        }
        return BorderSide(color: colorScheme.defaultBorder, width: 1.5);
      }),

      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.pressedItem;
        }
        if (states.contains(WidgetState.disabled)) {
          return colorScheme.disabledItem;
        }
        return colorScheme.staticItem;
      }),

      shape: const WidgetStatePropertyAll(CircleBorder()),

      elevation: const WidgetStatePropertyAll(0),

      splashFactory: NoSplash.splashFactory,
    );
  }
}

class _RoundedButtonColorScheme {
  final Color staticFill;

  final Color staticItem;

  final Color pressedFill;

  final Color pressedItem;

  final Color disabledFill;

  final Color disabledItem;

  final Color defaultBorder;

  final Color pressedBorder;

  final Color disabledBorder;

  _RoundedButtonColorScheme({
    required this.staticFill,
    required this.staticItem,
    required this.pressedFill,
    required this.pressedItem,
    required this.disabledFill,
    required this.disabledItem,
    required this.defaultBorder,
    required this.pressedBorder,
    required this.disabledBorder,
  });
}
