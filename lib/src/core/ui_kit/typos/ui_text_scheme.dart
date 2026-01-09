// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/typos/text_style_tokens.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'ui_text_scheme.tailor.dart';

@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
class UiTextScheme extends ThemeExtension<UiTextScheme>
    with _$UiTextSchemeTailorMixin {
  @override
  final UiTextStyle tokens;

  const UiTextScheme({required this.tokens});
}
