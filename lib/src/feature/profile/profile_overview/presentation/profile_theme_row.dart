import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_segmented_control/ui_segmented_control.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/settings/bloc/app_settings_bloc.dart';
import 'package:tails_mobile/src/feature/settings/model/app_settings.dart';
import 'package:tails_mobile/src/feature/settings/model/app_theme.dart';
import 'package:tails_mobile/src/feature/settings/widget/settings_scope.dart';

/// Строка «Оформление» с выбором темы: светлая, тёмная или системная.
///
/// Выбор применяется сразу и сохраняется в настройках приложения.
class ProfileThemeRow extends StatelessWidget {
  const ProfileThemeRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = SettingsScope.settingsOf(context);
    final selected = (settings.appTheme ?? AppTheme.defaultTheme).themeMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiNavRow(icon: Icons.dark_mode_outlined, title: l10n.profileTheme),
        UiSegmentedControl<ThemeMode>(
          options: [
            UiSegmentedOption(value: ThemeMode.light, label: l10n.profileThemeLight),
            UiSegmentedOption(value: ThemeMode.dark, label: l10n.profileThemeDark),
            UiSegmentedOption(value: ThemeMode.system, label: l10n.profileThemeSystem),
          ],
          selected: selected,
          onChanged: (mode) => _select(context, settings, mode),
        ),
        Padding(
          padding: const EdgeInsets.only(top: UiSpacing.x2, bottom: UiSpacing.x3),
          child: Text(
            l10n.profileThemeSystemHint,
            style: context.uiFonts.footnote.copyWith(color: context.uiPalette.ink3),
          ),
        ),
      ],
    );
  }

  void _select(BuildContext context, AppSettings settings, ThemeMode mode) {
    final current = (settings.appTheme ?? AppTheme.defaultTheme).themeMode;

    if (mode == current && settings.appTheme != null) {
      return;
    }

    TailsAnalytics.log(TailsAnalyticsEvents.appSettingChanged(setting: 'theme', value: mode.name));
    TailsAnalytics.setUserProperty(TailsAnalyticsUserProperty.appTheme, mode.name);

    SettingsScope.of(context, listen: false).add(
      AppSettingsEvent.updateAppSettings(
        appSettings: settings.copyWith(appTheme: AppTheme(themeMode: mode)),
      ),
    );
  }
}
