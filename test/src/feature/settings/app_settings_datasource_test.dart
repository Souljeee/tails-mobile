import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tails_mobile/src/feature/settings/data/app_settings_datasource.dart';
import 'package:tails_mobile/src/feature/settings/model/app_settings.dart';
import 'package:tails_mobile/src/feature/settings/model/app_theme.dart';

void main() {
  group('AppSettingsDatasource: тема', () {
    late AppSettingsDatasourceImpl datasource;

    setUp(() {
      SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
      datasource = AppSettingsDatasourceImpl(sharedPreferences: SharedPreferencesAsync());
    });

    test('пока пользователь не выбирал тему, настроек нет, а по умолчанию — системная', () async {
      expect(await datasource.getAppSettings(), isNull);
      expect(AppTheme.defaultTheme.themeMode, ThemeMode.system);
    });

    test('выбранная тема переживает перезапуск', () async {
      for (final mode in ThemeMode.values) {
        await datasource.setAppSettings(AppSettings(appTheme: AppTheme(themeMode: mode)));

        final restored = await AppSettingsDatasourceImpl(
          sharedPreferences: SharedPreferencesAsync(),
        ).getAppSettings();

        expect(restored?.appTheme?.themeMode, mode);
      }
    });
  });
}
