import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';

/// Оборачивает [child] в приложение с темой Design 2.0 для widget-тестов UI kit.
Widget uiTestApp(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? UiThemeData.lightTheme,
  locale: const Locale('ru'),
  localizationsDelegates: Localization.localizationDelegates,
  supportedLocales: Localization.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);
