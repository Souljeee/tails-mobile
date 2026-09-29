import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/colors/ui_color_scheme.dart';
import 'package:tails_mobile/src/core/ui_kit/colors/ui_palette.dart';
import 'package:tails_mobile/src/core/ui_kit/typos/text_style_tokens.dart';
import 'package:tails_mobile/src/core/ui_kit/typos/ui_text_scheme.dart';

/// Class of the app themes data.
abstract class UiThemeData {
  /// Light theme configuration.
  static final lightTheme = ThemeData(
    extensions: [_lightColorScheme, _lightPalette, _textScheme],
    brightness: Brightness.light,
  );

  /// Dark theme configuration.
  static final darkTheme = ThemeData(
    extensions: [_darkColorScheme, _darkPalette, _textScheme],
    brightness: Brightness.dark,
  );

  static final _lightColorScheme = UiColorScheme.light();

  static final _darkColorScheme = UiColorScheme.dark();

  static const _lightPalette = UiPalette.light();

  static const _darkPalette = UiPalette.dark();

  static final _textScheme = UiTextScheme(tokens: UiDefaultTextStyleTokens());
}
