import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:url_launcher/url_launcher.dart';

/// «О приложении»: версия и ссылки на юридические документы.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  /// Открывает документ во встроенном браузере (Safari View Controller / Custom Tabs). Пока ссылка не задана — сообщает, что документа нет.
  Future<void> _openDocument(BuildContext context, String url, {required String document}) async {
    final l10n = context.l10n;

    if (url.isEmpty) {
      showUiSnackBar(context, message: l10n.aboutDocumentSoon, kind: UiSnackBarKind.info);

      return;
    }

    TailsAnalytics.log(TailsAnalyticsEvents.legalLinkOpened(document));

    var opened = false;

    try {
      final uri = Uri.tryParse(url);

      opened = uri != null && await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    } catch (_) {
      opened = false;
    }

    if (!opened && context.mounted) {
      showUiSnackBar(context, message: l10n.aboutDocumentOpenError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final dependencies = DependenciesScope.of(context);
    final repository = dependencies.profileRepository;
    final config = dependencies.config;

    return Scaffold(
      backgroundColor: palette.canvas,
      body: Column(
        children: [
          UiTopBar(
            title: l10n.aboutTitle,
            backLabel: l10n.enterCodeBack,
            onBack: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(UiSpacing.x5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: UiSpacing.x4),
                    const Center(child: _AppMark()),
                    const SizedBox(height: UiSpacing.x4),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: fonts.displayS.copyWith(color: palette.ink),
                    ),
                    const SizedBox(height: UiSpacing.x1),
                    Text(
                      l10n.aboutVersion(repository.appVersion, repository.appBuildNumber),
                      textAlign: TextAlign.center,
                      style: fonts.monoMeta.copyWith(color: palette.ink2),
                    ),
                    const SizedBox(height: UiSpacing.x3),
                    Text(
                      l10n.aboutDescription,
                      textAlign: TextAlign.center,
                      style: fonts.body.copyWith(color: palette.ink2),
                    ),
                    const SizedBox(height: UiSpacing.x6),
                    UiSectionHeader(title: l10n.aboutDocumentsSection),
                    const SizedBox(height: UiSpacing.x2),
                    UiGroupedList(
                      dividerIndent: UiNavRow.leadingWidth,
                      children: [
                        UiNavRow(
                          icon: Icons.description_outlined,
                          title: l10n.aboutTerms,
                          onTap: () => _openDocument(context, config.termsUrl, document: 'terms'),
                        ),
                        UiNavRow(
                          icon: Icons.verified_user_outlined,
                          title: l10n.aboutPrivacy,
                          onTap: () =>
                              _openDocument(context, config.privacyUrl, document: 'privacy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: UiSpacing.x8),
                    Text(
                      l10n.aboutCopyright(DateTime.now().year),
                      textAlign: TextAlign.center,
                      style: fonts.monoMeta.copyWith(color: palette.ink3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Временный знак приложения: монограмма «Х» на акценте. Заменить утверждённым значком.
class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.accent,
        borderRadius: UiRadius.lgAll,
        boxShadow: UiShadows.e1,
      ),
      child: SizedBox.square(
        dimension: 96,
        child: Center(
          child: Text(
            'Х',
            style: context.uiFonts.displayM.copyWith(
              color: palette.surface,
              fontSize: 56,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
