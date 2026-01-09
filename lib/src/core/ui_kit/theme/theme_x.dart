import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/colors/ui_color_scheme.dart';
import 'package:tails_mobile/src/core/ui_kit/typos/text_style_tokens.dart';
import 'package:tails_mobile/src/core/ui_kit/typos/ui_text_scheme.dart';

extension ThemeX on BuildContext {
  UiTextStyle get uiFonts => uiTextScheme.tokens;

  UiColorScheme get uiColors => uiColorScheme;
}
