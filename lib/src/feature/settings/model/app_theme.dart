import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';

/// {@template app_theme}
/// An immutable class that holds properties needed to build a [ThemeData] for the app.
/// {@endtemplate}
@immutable
final class AppTheme with Diagnosticable {
  /// {@macro app_theme}
  const AppTheme({required this.themeMode});

  /// The type of theme to use.
  final ThemeMode themeMode;

  /// The default theme to use.
  static const defaultTheme = AppTheme(
    themeMode: ThemeMode.light,
  );

  /// Builds a [ThemeData] based on the [themeMode]
  ///
  /// This can also be used to add additional properties to the [ThemeData],
  /// such as extensions or custom properties.
  ThemeData buildThemeData(Brightness brightness) {
    switch (brightness) {
      case Brightness.dark:
        return UiThemeData.darkTheme;
      case Brightness.light:
        return UiThemeData.lightTheme;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<ThemeMode>('type', themeMode));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppTheme && themeMode == other.themeMode;

  @override
  int get hashCode => themeMode.hashCode;
}
