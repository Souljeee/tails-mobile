import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_switch_row/ui_switch_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/phone_format.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/profile/core/presentation/logout_flow.dart';
import 'package:tails_mobile/src/feature/profile/delete_account/domain/delete_account_bloc.dart';

/// Шаг 1 удаления аккаунта: что будет удалено и подтверждение, что пользователь это понимает.
///
/// По нажатию «Продолжить» запрашивается код — звонок на номер [phoneNumber]. Рядом
/// предлагается просто выйти из аккаунта: данные при этом сохраняются.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  late final DeleteAccountBloc _bloc = DeleteAccountBloc(
    profileRepository: DependenciesScope.of(context).profileRepository,
    petRepository: DependenciesScope.of(context).petRepository,
  );

  late final TapGestureRecognizer _logoutTap = TapGestureRecognizer()
    ..onTap = () => confirmAndLogout(context, phoneNumber: widget.phoneNumber);

  bool _acknowledged = false;

  @override
  void initState() {
    super.initState();

    _bloc.add(const DeleteAccountEvent.started());
  }

  @override
  void dispose() {
    _logoutTap.dispose();
    _bloc.close();

    super.dispose();
  }

  void _onStateChanged(BuildContext context, DeleteAccountState state) {
    final l10n = context.l10n;

    switch (state.status) {
      case DeleteAccountStatus.codeSent:
        if (state.wasCodeAlreadySent) {
          showUiSnackBar(
            context,
            message: l10n.deleteAccountCodeTooSoon,
            kind: UiSnackBarKind.info,
          );
        }

        DeleteAccountConfirmRoute(phoneNumber: widget.phoneNumber).push<void>(context);
      case DeleteAccountStatus.failure:
        showUiSnackBar(context, message: l10n.tryLater);
      case DeleteAccountStatus.idle ||
          DeleteAccountStatus.sendingCode ||
          DeleteAccountStatus.deleting ||
          DeleteAccountStatus.deleted:
        break;
    }
  }

  /// «Сексик и Мистерио», «Барсик, Мурка и Рекс».
  String _joinNames(List<String> names, String joiner) {
    if (names.length < 2) {
      return names.join();
    }

    return '${names.sublist(0, names.length - 1).join(', ')}$joiner${names.last}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Scaffold(
      backgroundColor: palette.canvas,
      body: Column(
        children: [
          UiTopBar(
            title: l10n.deleteAccountTitle,
            backLabel: l10n.enterCodeBack,
            onBack: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: BlocConsumer<DeleteAccountBloc, DeleteAccountState>(
              bloc: _bloc,
              listenWhen: (previous, current) => previous.revision != current.revision,
              listener: _onStateChanged,
              builder: (context, state) {
                final petNames = state.petNames;

                return SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(UiSpacing.x5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: UiIconBadge(
                                  icon: Icons.delete_outline,
                                  size: 64,
                                  iconSize: 28,
                                  foregroundColor: palette.danger,
                                  backgroundColor: palette.dangerTint,
                                ),
                              ),
                              const SizedBox(height: UiSpacing.x4),
                              Semantics(
                                header: true,
                                child: Text(
                                  l10n.deleteAccountHeadline,
                                  style: fonts.displayM.copyWith(color: palette.ink),
                                ),
                              ),
                              const SizedBox(height: UiSpacing.x2),
                              Text(
                                l10n.deleteAccountLead,
                                style: fonts.body.copyWith(color: palette.ink2),
                              ),
                              const SizedBox(height: UiSpacing.x5),
                              UiSectionHeader(title: l10n.deleteAccountWhatSection),
                              const SizedBox(height: UiSpacing.x2),
                              UiGroupedList(
                                dividerIndent: UiNavRow.leadingWidth,
                                children: [
                                  UiNavRow(
                                    icon: Icons.person_outline,
                                    title: l10n.deleteAccountItemProfile,
                                    subtitle: l10n.deleteAccountItemProfileHint(
                                      formatPhoneForDisplay(widget.phoneNumber),
                                    ),
                                  ),
                                  if (petNames.isNotEmpty)
                                    UiNavRow(
                                      icon: Icons.pets,
                                      title: l10n.petsCount(petNames.length),
                                      subtitle: l10n.deleteAccountItemPetsHint(
                                        _joinNames(petNames, l10n.deleteAccountNamesJoiner),
                                      ),
                                    ),
                                  UiNavRow(
                                    icon: Icons.event_outlined,
                                    title: l10n.deleteAccountItemEvents,
                                    subtitle: l10n.deleteAccountItemEventsHint,
                                  ),
                                ],
                              ),
                              const SizedBox(height: UiSpacing.x3),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x1),
                                child: Text.rich(
                                  TextSpan(
                                    style: fonts.footnote.copyWith(color: palette.ink2),
                                    children: [
                                      TextSpan(text: l10n.deleteAccountPauseHintPrefix),
                                      TextSpan(
                                        text: l10n.deleteAccountPauseHintLink,
                                        recognizer: _logoutTap,
                                        style: TextStyle(
                                          color: palette.accent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(text: l10n.deleteAccountPauseHintSuffix),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: UiSpacing.x4),
                              UiSwitchRow(
                                title: l10n.deleteAccountAcknowledge,
                                subtitle: l10n.deleteAccountAcknowledgeHint,
                                value: _acknowledged,
                                onChanged: (value) => setState(() => _acknowledged = value),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          UiSpacing.x5,
                          UiSpacing.x2,
                          UiSpacing.x5,
                          UiSpacing.x4,
                        ),
                        child: UiButton.main(
                          label: l10n.deleteAccountContinue,
                          staticFillColor: palette.dangerTint,
                          staticItemColor: palette.danger,
                          pressedFillColor: palette.dangerTint,
                          pressedItemColor: palette.danger,
                          isLoading: state.status == DeleteAccountStatus.sendingCode,
                          onPressed: _acknowledged && !state.isBusy
                              ? () => _bloc.add(const DeleteAccountEvent.sendCodeRequested())
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
