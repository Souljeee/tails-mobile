import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_code_input/ui_code_input.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_countdown_badge/ui_countdown_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_loader_overlay/loader_overlay.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_text_link/ui_text_link.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/phone_format.dart';
import 'package:tails_mobile/src/feature/auth/domain/auth/auth_bloc.dart';
import 'package:tails_mobile/src/feature/auth/domain/code_timer/code_timer_bloc.dart';
import 'package:tails_mobile/src/feature/auth/domain/send_code/send_code_bloc.dart';
import 'package:tails_mobile/src/feature/auth/presentation/auth_scope.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';

class EnterCodeScreen extends StatelessWidget {
  final String phoneNumber;

  const EnterCodeScreen({required this.phoneNumber, super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Scaffold(
      backgroundColor: palette.canvas,
      body: Column(
        children: [
          UiTopBar(
            title: '',
            backLabel: context.l10n.enterCodeBack,
            onBack: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: BlocConsumer<AuthBloc, AuthState>(
                bloc: DependenciesScope.of(context).authorizationBloc,
                listener: (context, state) {
                  if (state.status == AuthorizationStatus.authorized) {
                    // Важно: `CodeTimerBloc` живёт дольше экрана (dependency scope),
                    // поэтому при успешной авторизации нужно явно остановить таймер.
                    DependenciesScope.of(context).codeTimerBloc.add(const CodeTimerEvent.reset());
                  }

                  state.maybeMap(
                    processing: (_) {
                      LoaderOverlay.of(context).showLoader();
                    },
                    orElse: () {
                      LoaderOverlay.of(context).hideLoader();
                    },
                  );

                  state.mapOrNull(
                    error: (_) => showUiSnackBar(context, message: context.l10n.tryLater),
                  );
                },
                builder: (context, state) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
                                child: Column(
                                  children: [
                                    const SizedBox(height: UiSpacing.x4),
                                    const UiIconBadge(icon: Icons.call, size: 64, iconSize: 28),
                                    const SizedBox(height: UiSpacing.x5),
                                    Text(
                                      context.l10n.enterCodeTitle,
                                      style: fonts.displayS.copyWith(color: palette.ink),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: UiSpacing.x3),
                                    Text(
                                      context.l10n.enterCodeSubtitle,
                                      style: fonts.body.copyWith(color: palette.ink2),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: UiSpacing.x1),
                                    Text(
                                      formatPhoneForDisplay(phoneNumber),
                                      style: fonts.monoDigits.copyWith(color: palette.ink),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: UiSpacing.x6),
                                    UiCodeInput(
                                      onCompleted: (code) {
                                        AuthScope.of(context).login(phoneNumber, code);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: UiSpacing.x4),
                                child: _RetrySection(phoneNumber: phoneNumber),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RetrySection extends StatelessWidget {
  final String phoneNumber;

  const _RetrySection({required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CodeTimerBloc, CodeTimerState>(
      bloc: DependenciesScope.of(context).codeTimerBloc,
      builder: (context, timerState) {
        final isTimerActive = timerState.maybeMap(ticking: (_) => true, orElse: () => false);

        return isTimerActive ? const _RetryTimer() : _RetryButton(phoneNumber: phoneNumber);
      },
    );
  }
}

class _RetryButton extends StatefulWidget {
  final String phoneNumber;

  const _RetryButton({required this.phoneNumber});

  @override
  State<_RetryButton> createState() => _RetryButtonState();
}

class _RetryButtonState extends State<_RetryButton> {
  late final SendCodeBloc _sendCodeBloc;
  late final CodeTimerBloc _codeTimerBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final dependencies = DependenciesScope.of(context);
    _sendCodeBloc = SendCodeBloc(authRepository: dependencies.authRepository);
    _codeTimerBloc = dependencies.codeTimerBloc;
  }

  @override
  void dispose() {
    _sendCodeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CodeTimerBloc, CodeTimerState>(
      bloc: _codeTimerBloc,
      builder: (context, timerState) {
        final isEnabled = timerState.maybeMap(idle: (_) => true, orElse: () => false);

        return UiTextLink(
          label: context.l10n.callAgain,
          onTap: isEnabled
              ? () {
                  _sendCodeBloc.add(
                    SendCodeEvent.sendCodeRequested(
                      phoneNumber: widget.phoneNumber,
                      isResend: true,
                    ),
                  );
                  _codeTimerBloc.add(const CodeTimerEvent.started());
                }
              : null,
        );
      },
    );
  }
}

class _RetryTimer extends StatefulWidget {
  const _RetryTimer();

  @override
  State<_RetryTimer> createState() => _RetryTimerState();
}

class _RetryTimerState extends State<_RetryTimer> {
  late final _codeTimerBloc = DependenciesScope.of(context).codeTimerBloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CodeTimerBloc, CodeTimerState>(
      bloc: _codeTimerBloc,
      builder: (context, state) {
        if (state.secondsRemaining > 0) {
          return UiCountdownBadge(seconds: state.secondsRemaining);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
