import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_loader_overlay/loader_overlay.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_text_link/ui_text_link.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
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
                                    _EnterCodeField(
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

class _EnterCodeField extends StatefulWidget {
  final void Function(String code)? onCompleted;

  const _EnterCodeField({required this.onCompleted});

  @override
  State<_EnterCodeField> createState() => _EnterCodeFieldState();
}

class _EnterCodeFieldState extends State<_EnterCodeField> {
  static const int _length = 4;

  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  String get _code => _controllers.map((e) => e.text).join();

  void _goNext(int i) {
    if (i < _length - 1) {
      _focusNodes[i + 1].requestFocus();
    } else {
      _focusNodes[i].unfocus();
      if (_code.length == _length) widget.onCompleted?.call(_code);
    }
  }

  void _goPrev(int i) {
    if (i > 0) {
      _focusNodes[i - 1].requestFocus();
    } else {
      _focusNodes[i].unfocus();
    }
  }

  void _onChanged(int i, String v) {
    final digitsOnly = v.replaceAll(RegExp('[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      _controllers[i].text = '';

      _goPrev(i);

      return;
    }

    final ch = digitsOnly.characters.last;

    if (_controllers[i].text != ch) {
      _controllers[i].text = ch;

      _controllers[i].selection = const TextSelection.collapsed(offset: 1);
    }

    _goNext(i);
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (event) {
        for (final focusNode in _focusNodes) {
          focusNode.unfocus();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_length, (fieldIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x2),
            child: _CodeCell(
              controller: _controllers[fieldIndex],
              focusNode: _focusNodes[fieldIndex],
              semanticLabel: context.l10n.enterCodeDigitLabel(fieldIndex + 1, _length),
              textInputAction: fieldIndex == _length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              onChanged: (value) => _onChanged(fieldIndex, value),
              onSubmitted: (_) {
                if (fieldIndex == _length - 1) FocusScope.of(context).unfocus();
              },
            ),
          );
        }),
      ),
    );
  }
}

/// Ячейка ввода одной цифры кода: обводка и кольцо фокуса как у `UiTextField`.
class _CodeCell extends StatelessWidget {
  const _CodeCell({
    required this.controller,
    required this.focusNode,
    required this.semanticLabel,
    required this.textInputAction,
    required this.onChanged,
    required this.onSubmitted,
  });

  static const double _size = 64;

  final TextEditingController controller;
  final FocusNode focusNode;
  final String semanticLabel;
  final TextInputAction textInputAction;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: UiRadius.mdAll,
      borderSide: BorderSide(color: color, width: width),
    );

    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: UiRadius.mdAll,
            boxShadow: focusNode.hasFocus
                ? [BoxShadow(color: palette.accentTint, spreadRadius: 4)]
                : null,
          ),
          child: child,
        );
      },
      child: SizedBox.square(
        dimension: _size,
        child: Semantics(
          label: semanticLabel,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: textInputAction,
            maxLength: 1,
            style: context.uiFonts.monoDigits.copyWith(
              color: palette.ink,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: palette.accent,
            decoration: InputDecoration(
              filled: true,
              fillColor: palette.surface,
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: border(palette.controlLine, 1),
              enabledBorder: border(palette.controlLine, 1),
              focusedBorder: border(palette.accent, 2),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
      ),
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
                    SendCodeEvent.sendCodeRequested(phoneNumber: widget.phoneNumber),
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
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  late final _codeTimerBloc = DependenciesScope.of(context).codeTimerBloc;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return BlocBuilder<CodeTimerBloc, CodeTimerState>(
      bloc: _codeTimerBloc,
      builder: (context, state) {
        if (state.secondsRemaining > 0) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: UiRadius.fullAll,
              border: Border.all(color: palette.line),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4, vertical: UiSpacing.x3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, color: palette.accent, size: 24),
                  const SizedBox(width: UiSpacing.x3),
                  Text(
                    _formatTime(state.secondsRemaining),
                    style: context.uiFonts.monoDigits.copyWith(color: palette.ink),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
