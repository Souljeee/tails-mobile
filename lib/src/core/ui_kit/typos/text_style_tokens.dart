import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/generated/fonts.gen.dart';

// Файлов шрифта Gilroy в проекте нет, поэтому его имя остаётся строкой.
const String _gilroyFont = 'Gilroy';
const String _manropeFont = FontFamily.manrope;
const String _plexMonoFont = FontFamily.iBMPlexMono;

abstract class UiTextStyle {
  TextStyle get header80Regular;

  TextStyle get header76Help;

  TextStyle get header62Medium;

  TextStyle get header62Regular;

  TextStyle get header52Regular;

  TextStyle get header42Regular;

  TextStyle get header36Semibold;

  TextStyle get header32Semibold;

  TextStyle get header32Regular;

  TextStyle get header28Semibold;

  TextStyle get header24Semibold;

  TextStyle get header20Medium;

  TextStyle get text20Semibold;

  TextStyle get text16Regular;

  TextStyle get text16Medium;

  TextStyle get text16Semibold;

  TextStyle get text14Regular;

  TextStyle get text14Medium;

  TextStyle get text14Semibold;

  TextStyle get text12Regular;

  TextStyle get text12Medium;

  TextStyle get text12Semibold;

  // Design 2.0: Manrope
  TextStyle get displayL;

  TextStyle get displayM;

  TextStyle get displayS;

  TextStyle get headline;

  TextStyle get body;

  TextStyle get bodySemibold;

  TextStyle get bodyBold;

  TextStyle get callout;

  TextStyle get footnote;

  // Design 2.0: IBM Plex Mono
  TextStyle get monoMeta;

  TextStyle get monoEyebrow;

  TextStyle get monoDigits;
}

class UiDefaultTextStyleTokens extends UiTextStyle {
  @override
  TextStyle get header80Regular => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 80.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.8,
  );

  @override
  TextStyle get header76Help => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 76.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.76,
  );

  @override
  TextStyle get header62Medium => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 62.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.62,
  );

  @override
  TextStyle get header62Regular => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 62.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -1.24,
  );

  @override
  TextStyle get header52Regular => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 52.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.52,
  );

  @override
  TextStyle get header42Regular => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 42.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.84,
  );

  @override
  TextStyle get header36Semibold => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 36.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.72,
  );

  @override
  TextStyle get header32Semibold => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 32.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.32,
  );

  @override
  TextStyle get header32Regular => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 32.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.32,
  );

  @override
  TextStyle get header28Semibold => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 28.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.56,
  );

  @override
  TextStyle get header24Semibold => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );

  @override
  TextStyle get header20Medium => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 20.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.2,
  );

  @override
  TextStyle get text20Semibold => const TextStyle(
    fontFamily: _gilroyFont,
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  @override
  TextStyle get text16Regular => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.16,
  );

  @override
  TextStyle get text16Medium => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.16,
  );

  @override
  TextStyle get text16Semibold => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );

  @override
  TextStyle get text14Regular => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  @override
  TextStyle get text14Medium => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
  );

  @override
  TextStyle get text14Semibold => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );

  @override
  TextStyle get text12Regular => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.0,
  );

  @override
  TextStyle get text12Medium => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.0,
  );

  @override
  TextStyle get text12Semibold => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );

  @override
  TextStyle get displayL => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 34.0,
    height: 42 / 34,
    fontWeight: FontWeight.w800,
  );

  @override
  TextStyle get displayM => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 28.0,
    height: 34 / 28,
    fontWeight: FontWeight.w800,
  );

  @override
  TextStyle get displayS => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 24.0,
    height: 30 / 24,
    fontWeight: FontWeight.w800,
  );

  @override
  TextStyle get headline => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 17.0,
    height: 24 / 17,
    fontWeight: FontWeight.w700,
  );

  @override
  TextStyle get body => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16.0,
    height: 22 / 16,
    fontWeight: FontWeight.w500,
  );

  @override
  TextStyle get bodySemibold => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16.0,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
  );

  @override
  TextStyle get bodyBold => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 16.0,
    height: 22 / 16,
    fontWeight: FontWeight.w700,
  );

  @override
  TextStyle get callout => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 15.0,
    height: 20 / 15,
    fontWeight: FontWeight.w600,
  );

  @override
  TextStyle get footnote => const TextStyle(
    fontFamily: _manropeFont,
    fontSize: 13.0,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
  );

  @override
  TextStyle get monoMeta => const TextStyle(
    fontFamily: _plexMonoFont,
    fontSize: 13.0,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
  );

  @override
  TextStyle get monoEyebrow => const TextStyle(
    fontFamily: _plexMonoFont,
    fontSize: 13.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.6,
  );

  @override
  TextStyle get monoDigits =>
      const TextStyle(fontFamily: _plexMonoFont, fontSize: 16.0, fontWeight: FontWeight.w500);
}
