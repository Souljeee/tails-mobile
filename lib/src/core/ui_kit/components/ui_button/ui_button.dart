import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/typos/text_style_tokens.dart';

enum UiButtonType { main, secondary }

enum UiButtonSize { s, m }

class UiButton extends StatelessWidget {
  final String label;

  final VoidCallback? onPressed;

  final UiButtonSize? size;

  final UiButtonType _type;

  final IconData? icon;

  final Color? staticFillColor,
      staticItemColor,
      pressedFillColor,
      pressedItemColor,
      disabledItemColor,
      disabledFillColor,
      defaultBorderColor,
      pressedBorderColor,
      disabledBorderColor;

  const UiButton.main({
    required this.label,
    this.onPressed,
    this.size,
    this.staticFillColor,
    this.staticItemColor,
    this.pressedFillColor,
    this.pressedItemColor,
    this.disabledFillColor,
    this.disabledItemColor,
    this.defaultBorderColor,
    this.pressedBorderColor,
    this.disabledBorderColor,
    this.icon,
    super.key,
  }) : _type = UiButtonType.main;

  const UiButton.secondary({
    required this.label,
    this.onPressed,
    this.size,
    this.staticFillColor,
    this.staticItemColor,
    this.pressedFillColor,
    this.pressedItemColor,
    this.disabledFillColor,
    this.disabledItemColor,
    this.pressedBorderColor,
    this.disabledBorderColor,
    this.defaultBorderColor,
    this.icon,
    super.key,
  }) : _type = UiButtonType.secondary;

  @override
  Widget build(BuildContext context) {
    final sizeProps = _getSizeProperties();

    return ElevatedButton(
      style: _createButtonStyle(context),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: sizeProps.textStyle,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(
              icon,
              size: 24,
              color: context.uiColors.white,
            )
          ],
        ],
      ),
    );
  }

  _ButtonColorScheme _getColorScheme(BuildContext context) {
    final colors = context.uiColors;
    const  transparent = Colors.transparent;

    switch (_type) {
      case UiButtonType.main:
        return _ButtonColorScheme(
          staticFill: staticFillColor ?? colors.orangePrimary,
          staticItem: staticItemColor ?? colors.white,
          pressedFill: pressedFillColor ?? colors.lightOrange,
          pressedItem: pressedItemColor ?? colors.white,
          disabledFill: disabledFillColor ?? colors.orangePrimary.withValues(alpha: 0.3),
          disabledItem: disabledItemColor ?? colors.white,
          defaultBorder: defaultBorderColor ?? transparent,
          pressedBorder: pressedBorderColor ?? transparent,
          disabledBorder: disabledBorderColor ?? transparent,
        );

      case UiButtonType.secondary:
        return _ButtonColorScheme(
          staticFill: staticFillColor ?? transparent,
          staticItem: staticItemColor ?? colors.orangePrimary,
          pressedFill: pressedFillColor ?? transparent,
          pressedItem: pressedItemColor ?? colors.lightOrange,
          disabledFill: disabledFillColor ?? transparent,
          disabledItem: disabledItemColor ?? colors.lightOrange,
          defaultBorder: defaultBorderColor ?? colors.orangePrimary,
          pressedBorder: pressedBorderColor ?? colors.lightOrange,
          disabledBorder: disabledBorderColor ?? colors.blue100.withValues(alpha: 0.5),
        );
    }
  }

  _ButtonSizeProperties _getSizeProperties() {
    switch (size) {
      case UiButtonSize.s:
        return _ButtonSizeProperties(
          textStyle: UiDefaultTextStyleTokens().text16Regular,
          height: 36,
          borderRadius: 26,
        );

      default:
        return _ButtonSizeProperties(
          textStyle: UiDefaultTextStyleTokens().text20Semibold,
          height: 56,
          borderRadius: 26,
        );
    }
  }

  ButtonStyle _createButtonStyle(BuildContext context) {
    final colorScheme = _getColorScheme(context);
    final sizeProps = _getSizeProperties();

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
      fixedSize: WidgetStatePropertyAll(Size.fromHeight(sizeProps.height)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(sizeProps.borderRadius),
        ),
      ),
      elevation: const WidgetStatePropertyAll(0),
      splashFactory: NoSplash.splashFactory,
    );
  }
}

class _ButtonColorScheme {
  final Color staticFill;

  final Color staticItem;

  final Color pressedFill;

  final Color pressedItem;

  final Color disabledFill;

  final Color disabledItem;

  final Color defaultBorder;

  final Color pressedBorder;

  final Color disabledBorder;

  _ButtonColorScheme({
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

class _ButtonSizeProperties {
  final TextStyle textStyle;

  final double height;

  final double borderRadius;

  _ButtonSizeProperties({
    required this.textStyle,
    required this.height,
    required this.borderRadius,
  });
}
