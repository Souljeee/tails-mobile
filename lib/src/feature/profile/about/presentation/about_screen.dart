import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/legal_document_opener.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';

/// «О приложении»: версия и ссылки на юридические документы.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
                          onTap: () => openLegalDocument(
                            context,
                            url: config.termsUrl,
                            document: LegalDocument.terms,
                          ),
                        ),
                        UiNavRow(
                          icon: Icons.verified_user_outlined,
                          title: l10n.aboutPrivacy,
                          onTap: () => openLegalDocument(
                            context,
                            url: config.privacyUrl,
                            document: LegalDocument.privacy,
                          ),
                        ),
                        UiNavRow(
                          icon: Icons.fact_check_outlined,
                          title: l10n.aboutConsent,
                          onTap: () => openLegalDocument(
                            context,
                            url: config.consentUrl,
                            document: LegalDocument.consent,
                          ),
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

/// Знак приложения: утверждённая иконка со скруглением и тенью из токенов UI kit.
class _AppMark extends StatelessWidget {
  const _AppMark();

  static const double _size = 96;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(borderRadius: UiRadius.lgAll, boxShadow: UiShadows.e1),
      child: ClipRRect(
        borderRadius: UiRadius.lgAll,
        child: context.uiImages.appIcon.image(
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          excludeFromSemantics: true,
        ),
      ),
    );
  }
}
