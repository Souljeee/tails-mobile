import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';

enum UiButtonType { main, secondary }

/// Размер кнопки: [l] — 56 pt (основное действие), [m] — 44 pt.
enum UiButtonSize { m, l }

class UiButton extends StatelessWidget {
  final String label;

  final VoidCallback? onPressed;

  /// По умолчанию [UiButtonSize.l].
  final UiButtonSize? size;

  final UiButtonType _type;

  final IconData? icon;

  final bool isLoading;

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
    this.isLoading = false,
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
    this.isLoading = false,
    super.key,
  }) : _type = UiButtonType.secondary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = _getColorScheme(context);
    final sizeProps = _getSizeProperties(context);

    return ElevatedButton(
      style: _createButtonStyle(colorScheme, sizeProps),
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading) ...[
            Center(
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(color: colorScheme.staticItem, strokeWidth: 3),
              ),
            ),
          ] else ...[
            Flexible(
              child: Text(
                label,
                style: sizeProps.textStyle,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 24)],
          ],
        ],
      ),
    );
  }

  _ButtonColorScheme _getColorScheme(BuildContext context) {
    final palette = context.uiPalette;
    const transparent = Colors.transparent;

    switch (_type) {
      case UiButtonType.main:
        return _ButtonColorScheme(
          staticFill: staticFillColor ?? palette.accent,
          staticItem: staticItemColor ?? palette.surface,
          pressedFill: pressedFillColor ?? palette.accentPressed,
          pressedItem: pressedItemColor ?? palette.surface,
          disabledFill: disabledFillColor ?? palette.sunken,
          disabledItem: disabledItemColor ?? palette.ink3,
          defaultBorder: defaultBorderColor ?? transparent,
          pressedBorder: pressedBorderColor ?? transparent,
          disabledBorder: disabledBorderColor ?? transparent,
        );

      case UiButtonType.secondary:
        return _ButtonColorScheme(
          staticFill: staticFillColor ?? transparent,
          staticItem: staticItemColor ?? palette.accent,
          pressedFill: pressedFillColor ?? palette.accentTint,
          pressedItem: pressedItemColor ?? palette.accentPressed,
          disabledFill: disabledFillColor ?? transparent,
          disabledItem: disabledItemColor ?? palette.ink3,
          defaultBorder: defaultBorderColor ?? palette.accent,
          pressedBorder: pressedBorderColor ?? palette.accentPressed,
          disabledBorder: disabledBorderColor ?? palette.line,
        );
    }
  }

  _ButtonSizeProperties _getSizeProperties(BuildContext context) {
    switch (size) {
      case UiButtonSize.m:
        return _ButtonSizeProperties(
          textStyle: context.uiFonts.callout,
          height: UiSizes.buttonM,
          borderRadius: UiRadius.md,
        );

      case UiButtonSize.l:
      case null:
        return _ButtonSizeProperties(
          textStyle: context.uiFonts.headline,
          height: UiSizes.buttonL,
          borderRadius: UiRadius.md,
        );
    }
  }

  ButtonStyle _createButtonStyle(_ButtonColorScheme colorScheme, _ButtonSizeProperties sizeProps) {
    // Во время загрузки кнопка неактивна, но выглядит как обычная.
    bool isDisabled(Set<WidgetState> states) => states.contains(WidgetState.disabled) && !isLoading;

    Color resolveItemColor(Set<WidgetState> states) {
      if (isDisabled(states)) {
        return colorScheme.disabledItem;
      }
      if (states.contains(WidgetState.pressed)) {
        return colorScheme.pressedItem;
      }
      return colorScheme.staticItem;
    }

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (isDisabled(states)) {
          return colorScheme.disabledFill;
        }
        if (states.contains(WidgetState.pressed)) {
          return colorScheme.pressedFill;
        }
        return colorScheme.staticFill;
      }),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      side: WidgetStateProperty.resolveWith((states) {
        if (isDisabled(states)) {
          return BorderSide(color: colorScheme.disabledBorder, width: 1.5);
        }
        if (states.contains(WidgetState.pressed)) {
          return BorderSide(color: colorScheme.pressedBorder, width: 1.5);
        }
        return BorderSide(color: colorScheme.defaultBorder, width: 1.5);
      }),
      foregroundColor: WidgetStateProperty.resolveWith(resolveItemColor),
      iconColor: WidgetStateProperty.resolveWith(resolveItemColor),
      fixedSize: WidgetStatePropertyAll(Size.fromHeight(sizeProps.height)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(sizeProps.borderRadius)),
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
