// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:theme_tailor_annotation/theme_tailor_annotation.dart';

part 'ui_color_scheme.tailor.dart';

@immutable
@TailorMixin(themeGetter: ThemeGetter.onBuildContext)
class UiColorScheme extends ThemeExtension<UiColorScheme> with _$UiColorSchemeTailorMixin {
  // Black Shades
  @override
  final Color black100;
  @override
  final Color black80;
  @override
  final Color black60;
  @override
  final Color black50;
  @override
  final Color black40;
  @override
  final Color black30;
  @override
  final Color black20;
  @override
  final Color black5;

  // Primary Colors
  @override
  final Color orangePrimary;
  @override
  final Color blue100;
  @override
  final Color blueDark;
  @override
  final Color blueHover;
  @override
  final Color blueLight;
  @override
  final Color blueStroke;
  @override
  final Color blueLight2;
  @override
  final Color blue20;
  @override
  final Color blue10;

  // Background Colors
  @override
  final Color grayMain;
  @override
  final Color white;
  @override
  final Color orangeBg;

  // Additional Colors
  @override
  final Color red;
  @override
  final Color darkGreen;
  @override
  final Color purple;
  @override
  final Color blue;
  @override
  final Color green;
  @override
  final Color orange;
  @override
  final Color lightRed;
  @override
  final Color lightDarkGreen;
  @override
  final Color lightPurple;
  @override
  final Color lightBlue;
  @override
  final Color lightGreen;
  @override
  final Color lightOrange;
  @override
  final Color gray;
  @override
  final Color blueGray;
  @override
  final Color brown;

  const UiColorScheme({
    required this.black100,
    required this.black80,
    required this.black60,
    required this.black50,
    required this.black40,
    required this.black30,
    required this.black20,
    required this.black5,
    required this.orangePrimary,
    required this.blue100,
    required this.blueDark,
    required this.blueHover,
    required this.blueLight,
    required this.blueStroke,
    required this.blueLight2,
    required this.blue20,
    required this.blue10,
    required this.grayMain,
    required this.white,
    required this.orangeBg,
    required this.red,
    required this.darkGreen,
    required this.purple,
    required this.blue,
    required this.green,
    required this.orange,
    required this.lightRed,
    required this.lightDarkGreen,
    required this.lightPurple,
    required this.lightBlue,
    required this.lightGreen,
    required this.lightOrange,
    required this.gray,
    required this.blueGray,
    required this.brown,
  });

  /// Light Theme
  UiColorScheme.light()
    : black100 = const Color(0xFF1A1A1A),
      black80 = const Color(0xFF303030),
      black60 = const Color(0xFF6A6A6A),
      black50 = const Color(0xFF828282),
      black40 = const Color(0xFFB0B0B0),
      black30 = const Color(0xFFDBDBDB),
      black20 = const Color(0xFFEDEDED),
      black5 = const Color(0xFFF6F6F6),
      orangePrimary = const Color(0xFFED8D2D),
      blue100 = const Color(0xFF005EFF),
      blueDark = const Color(0xFF2755A4),
      blueHover = const Color(0xFF4388FF),
      blueLight = const Color(0xFFC7DBFF),
      blueStroke = const Color(0xFFE3EDFF),
      blueLight2 = const Color(0xFFEDF4FF),
      blue20 = const Color(0xFF005EFF),
      blue10 = const Color(0xFF005EFF),
      grayMain = const Color(0xFFF3F3F3),
      white = const Color(0xFFFFFFFF),
      orangeBg = const Color(0xFFF7F1EB),
      red = const Color(0xFFFF1010),
      darkGreen = const Color(0xFF27A474),
      purple = const Color(0xFF6F00FF),
      blue = const Color(0xFF5E96F7),
      green = const Color(0xFFB2E189),
      orange = const Color(0xFFF99D00),
      lightRed = const Color(0xFFFFE6E6),
      lightDarkGreen = const Color(0xFFD7F5E3),
      lightPurple = const Color(0xFFF3EAFF),
      lightBlue = const Color(0xFFC7DBFF),
      lightGreen = const Color(0xFFDBFBC0),
      lightOrange = const Color(0xFFF5C8A4),
      gray = const Color(0xFF6C6F89),
      blueGray = const Color(0xFF9AA9B5),
      brown = const Color(0xFF99724B);

  /// Dark Theme
  UiColorScheme.dark()
    : black100 = const Color(0xFF1A1A1A),
      black80 = const Color(0xFF303030),
      black60 = const Color(0xFF6A6A6A),
      black50 = const Color(0xFF828282),
      black40 = const Color(0xFFB0B0B0),
      black30 = const Color(0xFFDBDBDB),
      black20 = const Color(0xFFEDEDED),
      black5 = const Color(0xFFF9F9F9),
      orangePrimary = const Color(0xFFED8D2D),
      blue100 = const Color(0xFF6D38FF),
      blueDark = const Color(0xFF2755A4),
      blueHover = const Color(0xFF4388FF),
      blueLight = const Color(0xFFE4EAF4),
      blueStroke = const Color(0xFFE3EDFF),
      blueLight2 = const Color(0xFFEDF4FF),
      blue20 = const Color(0xFF005EFF),
      blue10 = const Color(0xFF005EFF),
      grayMain = const Color(0xFF222222),
      white = const Color(0xFFFFFFFF),
      orangeBg = const Color(0xFFF7F1EB),
      red = const Color(0xFFFF607D),
      darkGreen = const Color(0xFF27A474),
      purple = const Color(0xFF6F00FF),
      blue = const Color(0xFF5E96F7),
      green = const Color(0xFFB2E189),
      orange = const Color(0xFFF99D00),
      lightRed = const Color(0xFFFFE6E6),
      lightDarkGreen = const Color(0xFFD7F5E3),
      lightPurple = const Color(0xFFF3EAFF),
      lightBlue = const Color(0xFFC7DBFF),
      lightGreen = const Color(0xFFDBFBC0),
      lightOrange = const Color(0xFFF5C8A4),
      gray = const Color(0xFF6C6F89),
      blueGray = const Color(0xFF9AA9B5),
      brown = const Color(0xFF99724B);
}
