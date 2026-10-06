import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/analytics/integrations/analytics_impression.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_errors/ui_fetching_error.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_notice_banner/ui_notice_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';
import 'package:tails_mobile/src/feature/profile/notifications_settings/domain/notifications_settings_bloc.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen>
    with WidgetsBindingObserver {
  late final NotificationsSettingsBloc _bloc = NotificationsSettingsBloc(
    profileRepository: DependenciesScope.of(context).profileRepository,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _bloc.add(const NotificationsSettingsEvent.started());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Пользователь мог разрешить уведомления в настройках телефона и вернуться.
    if (state == AppLifecycleState.resumed) {
      _bloc.add(const NotificationsSettingsEvent.systemStatusChecked());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.uiPalette.canvas,
      body: Column(
        children: [
          UiTopBar(
            title: l10n.notificationsSettingsTitle,
            backLabel: l10n.enterCodeBack,
            onBack: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: BlocConsumer<NotificationsSettingsBloc, NotificationsSettingsState>(
              bloc: _bloc,
              listenWhen: (previous, current) => current.saveFailures > previous.saveFailures,
              listener: (context, state) => showUiSnackBar(context, message: l10n.tryLater),
              builder: (context, state) {
                return switch (state.status) {
                  NotificationsSettingsStatus.loading => const _SettingsShimmer(),
                  NotificationsSettingsStatus.failure => UiFetchingError(
                    onRetry: () => _bloc.add(const NotificationsSettingsEvent.started()),
                  ),
                  NotificationsSettingsStatus.ready => _SettingsList(
                    state: state,
                    onToggle: (category, {required enabled}) => _bloc.add(
                      NotificationsSettingsEvent.toggled(category: category, enabled: enabled),
                    ),
                    onOpenSettings: () =>
                        _bloc.add(const NotificationsSettingsEvent.openSettingsRequested()),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsList extends StatelessWidget {
  const _SettingsList({required this.state, required this.onToggle, required this.onOpenSettings});

  final NotificationsSettingsState state;
  final void Function(NotificationCategory category, {required bool enabled}) onToggle;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = state.settings;

    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final blocked = state.isBlockedBySystem;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(UiSpacing.x5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (blocked) ...[
              AnalyticsImpression(
                onShown: () {
                  TailsAnalytics.log(TailsAnalyticsEvents.notificationsDisabledBannerShown);
                  TailsAnalytics.setUserProperty(
                    TailsAnalyticsUserProperty.pushStatus,
                    'system_blocked',
                  );
                },
                child: UiNoticeBanner(
                  title: l10n.notificationsBlockedTitle,
                  text: l10n.notificationsBlockedText,
                  actionLabel: l10n.notificationsBlockedAction,
                  onAction: onOpenSettings,
                ),
              ),
              const SizedBox(height: UiSpacing.x4),
            ],
            Text(l10n.notificationsSettingsIntro, style: fonts.body.copyWith(color: palette.ink2)),
            const SizedBox(height: UiSpacing.x4),
            UiSectionHeader(title: l10n.notificationsSettingsSection),
            const SizedBox(height: UiSpacing.x2),
            UiGroupedList(
              dividerIndent: UiNavRow.leadingWidth,
              children: [
                for (final category in NotificationCategory.values)
                  UiNavRow.toggle(
                    icon: _icon(category),
                    title: _title(l10n, category),
                    isOn: settings?.isEnabled(category) ?? true,
                    // Пока уведомления запрещены в системе, выбор сохраняется, но не меняется.
                    enabled: !blocked,
                    onChanged: (value) => onToggle(category, enabled: value),
                  ),
              ],
            ),
            const SizedBox(height: UiSpacing.x3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x1),
              child: Text(
                blocked
                    ? l10n.notificationsSettingsFooterBlocked
                    : l10n.notificationsSettingsFooter,
                style: fonts.footnote.copyWith(color: palette.ink3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(NotificationCategory category) => switch (category) {
    NotificationCategory.walks => Icons.directions_walk,
    NotificationCategory.feeding => Icons.restaurant,
    NotificationCategory.medications => Icons.medication_outlined,
    NotificationCategory.vaccinations => Icons.vaccines_outlined,
    NotificationCategory.vetVisits => Icons.local_hospital_outlined,
  };

  String _title(AppLocalizations l10n, NotificationCategory category) => switch (category) {
    NotificationCategory.walks => l10n.notificationWalks,
    NotificationCategory.feeding => l10n.notificationFeeding,
    NotificationCategory.medications => l10n.notificationMedications,
    NotificationCategory.vaccinations => l10n.notificationVaccinations,
    NotificationCategory.vetVisits => l10n.notificationVetVisits,
  };
}

class _SettingsShimmer extends StatelessWidget {
  const _SettingsShimmer();

  @override
  Widget build(BuildContext context) {
    return const UiKitShimmer(
      child: Padding(
        padding: EdgeInsets.all(UiSpacing.x5),
        child: UiKitShimmerLoading(height: 280, borderRadius: UiRadius.lgAll),
      ),
    );
  }
}
