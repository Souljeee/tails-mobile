import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/generated/fonts.gen.dart';

const String _manropeFont = FontFamily.manrope;
const String _plexMonoFont = FontFamily.iBMPlexMono;

abstract class UiTextStyle {
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
