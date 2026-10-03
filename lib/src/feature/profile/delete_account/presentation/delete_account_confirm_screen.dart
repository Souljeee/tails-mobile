import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_countdown_badge/ui_countdown_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_text_link/ui_text_link.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/phone_format.dart';
import 'package:tails_mobile/src/feature/auth/domain/code_timer/code_timer_bloc.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/profile/delete_account/domain/delete_account_bloc.dart';

/// Шаг 2 удаления аккаунта: ввод кода из звонка и окончательное подтверждение.
class DeleteAccountConfirmScreen extends StatefulWidget {
  const DeleteAccountConfirmScreen({required this.phoneNumber, super.key});

  final String phoneNumber;

  @override
  State<DeleteAccountConfirmScreen> createState() => _DeleteAccountConfirmScreenState();
}

class _DeleteAccountConfirmScreenState extends State<DeleteAccountConfirmScreen> {
  static const int _codeLength = 4;

  late final DeleteAccountBloc _bloc = DeleteAccountBloc(
    profileRepository: DependenciesScope.of(context).profileRepository,
    petRepository: DependenciesScope.of(context).petRepository,
  );

  // Свой таймер: общий `CodeTimerBloc` принадлежит входу и не должен мешаться с удалением.
  final CodeTimerBloc _timerBloc = CodeTimerBloc();

  final UiTextFieldController _codeController = UiTextFieldController();

  bool get _isCodeComplete => _codeController.text.length == _codeLength;

  @override
  void initState() {
    super.initState();

    _codeController.addListener(() => setState(() {}));

    // Код отправлен на предыдущем шаге: повторный звонок станет доступен через минуту.
    _timerBloc.add(const CodeTimerEvent.started());
  }

  @override
  void dispose() {
    _bloc.close();
    _timerBloc.close();
    _codeController.dispose();

    super.dispose();
  }

  void _onStateChanged(BuildContext context, DeleteAccountState state) {
    final l10n = context.l10n;

    switch (state.status) {
      case DeleteAccountStatus.deleted:
        // Токены сервер уже отозвал; локальную сессию закроет экран «Аккаунт удалён».
        const AccountDeletedRoute().go(context);
      case DeleteAccountStatus.codeSent:
        _timerBloc.add(const CodeTimerEvent.started());
      case DeleteAccountStatus.failure:
        if (state.failure == DeleteAccountFailure.generic) {
          showUiSnackBar(context, message: l10n.tryLater);
        } else {
          // Неверный код: очищаем поле, ошибка остаётся под ним.
          _codeController.clear();
        }
      case DeleteAccountStatus.idle ||
          DeleteAccountStatus.sendingCode ||
          DeleteAccountStatus.deleting:
        break;
    }
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
                final isDeleting = state.status == DeleteAccountStatus.deleting;
                final invalidCode = state.failure == DeleteAccountFailure.invalidCode;

                return SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.all(UiSpacing.x5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Semantics(
                                header: true,
                                child: Text(
                                  l10n.deleteAccountConfirmTitle,
                                  style: fonts.displayM.copyWith(color: palette.ink),
                                ),
                              ),
                              const SizedBox(height: UiSpacing.x2),
                              Text(
                                l10n.deleteAccountConfirmLead(
                                  formatPhoneForDisplay(widget.phoneNumber),
                                ),
                                style: fonts.body.copyWith(color: palette.ink2),
                              ),
                              const SizedBox(height: UiSpacing.x5),
                              UiTextField(
                                controller: _codeController,
                                labelText: l10n.deleteAccountCodeLabel,
                                autofocus: true,
                                enabled: !isDeleting,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                inputMask: '#' * _codeLength,
                                inputTextStyle: fonts.monoDigits.copyWith(
                                  color: palette.ink,
                                  fontSize: 18,
                                ),
                                errorText: invalidCode
                                    ? (state.failureMessage ?? l10n.deleteAccountCodeInvalid)
                                    : null,
                              ),
                              const SizedBox(height: UiSpacing.x2),
                              _ResendSection(
                                timerBloc: _timerBloc,
                                onResend: () =>
                                    _bloc.add(const DeleteAccountEvent.sendCodeRequested()),
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
                          label: l10n.deleteAccountConfirm,
                          staticFillColor: palette.dangerTint,
                          staticItemColor: palette.danger,
                          pressedFillColor: palette.dangerTint,
                          pressedItemColor: palette.danger,
                          isLoading: isDeleting,
                          onPressed: _isCodeComplete && !state.isBusy
                              ? () => _bloc.add(
                                  DeleteAccountEvent.deleteRequested(code: _codeController.text),
                                )
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

/// «Позвонить ещё раз через 0:42», а по истечении минуты — ссылка «Перезвонить еще раз».
class _ResendSection extends StatelessWidget {
  const _ResendSection({required this.timerBloc, required this.onResend});

  final CodeTimerBloc timerBloc;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return BlocBuilder<CodeTimerBloc, CodeTimerState>(
      bloc: timerBloc,
      builder: (context, state) {
        if (state.secondsRemaining > 0) {
          return Text(
            context.l10n.deleteAccountResendIn(UiCountdownBadge.format(state.secondsRemaining)),
            style: context.uiFonts.footnote.copyWith(color: palette.ink3),
          );
        }

        return Align(
          alignment: Alignment.centerLeft,
          child: UiTextLink(label: context.l10n.callAgain, onTap: onResend),
        );
      },
    );
  }
}
