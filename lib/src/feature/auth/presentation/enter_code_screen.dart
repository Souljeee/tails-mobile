import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_loader_overlay/loader_overlay.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/auth/domain/auth/auth_bloc.dart';
import 'package:tails_mobile/src/feature/auth/domain/code_timer/code_timer_bloc.dart';
import 'package:tails_mobile/src/feature/auth/domain/send_code/send_code_bloc.dart';
import 'package:tails_mobile/src/feature/auth/presentation/auth_scope.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';

class EnterCodeScreen extends StatelessWidget {
  final String phoneNumber;

  const EnterCodeScreen({
    required this.phoneNumber,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.uiColors.grayMain,
      appBar: AppBar(
        backgroundColor: context.uiColors.grayMain,
        leading: IconButton(
          onPressed: () {
            Navigator.maybePop(context);
          },
          icon: Icon(
            Icons.keyboard_arrow_left,
            size: 32,
            color: context.uiColors.black100,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          bloc: DependenciesScope.of(context).authorizationBloc,
          listener: (context, state) {
            // После успешной авторизации уходим на главный экран.
            // Это страхует от ситуаций, когда redirect не пересчитался вовремя.
            // if (state.status == AuthorizationStatus.authorized) {
            //   const PetsRoute().go(context);
            //   return;
            // }

            state.maybeMap(
              processing: (_) {
                LoaderOverlay.of(context).showLoader();
              },
              orElse: () {
                LoaderOverlay.of(context).hideLoader();
              },
            );

            state.mapOrNull(
              error: (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.tryLater,
                      style: context.uiFonts.text16Medium.copyWith(color: context.uiColors.white),
                    ),
                    backgroundColor: context.uiColors.red,
                  ),
                );
              },
            );
          },
          builder: (context, state) {
            return Column(
              children: [
                const SizedBox(height: 28),
                const _CallIcon(),
                const SizedBox(height: 16),
                Text(
                  context.l10n.enterCodeTitle,
                  style: context.uiFonts.header28Semibold.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.enterCodeSubtitle,
                  style: context.uiFonts.text16Medium.copyWith(color: context.uiColors.black60),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  phoneNumber,
                  style: context.uiFonts.text16Medium.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _EnterCodeField(
                  onCompleted: (code) {
                    AuthScope.of(context).login(phoneNumber, code);
                  },
                ),
                const Spacer(),
                _RetrySection(phoneNumber: phoneNumber),
              ],
            );
          },
        ),
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
        final isTimerActive = timerState.maybeMap(
          ticking: (_) => true,
          orElse: () => false,
        );

        return isTimerActive ? const _RetryTimer() : _RetryButton(phoneNumber: phoneNumber);
      },
    );
  }
}

class _CallIcon extends StatelessWidget {
  const _CallIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.uiColors.orangeBg,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.call,
            size: 32,
            color: context.uiColors.orangePrimary,
          ),
        ),
      ),
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
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());

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
    if (i < 3) {
      _focusNodes[i + 1].requestFocus();
    } else {
      _focusNodes[i].unfocus();
      if (_code.length == 4) widget.onCompleted?.call(_code);
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
        children: List.generate(
          4,
          (fieldIndex) {
            return Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              child: TextField(
                controller: _controllers[fieldIndex],
                focusNode: _focusNodes[fieldIndex],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                textInputAction: fieldIndex == 3 ? TextInputAction.done : TextInputAction.next,
                maxLength: 1,
                style: context.uiFonts.header20Medium,
                cursorColor: context.uiColors.orangePrimary,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: context.uiColors.white,
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: context.uiColors.orangePrimary,
                      width: 2,
                    ),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) => _onChanged(fieldIndex, value),
                onSubmitted: (_) {
                  if (fieldIndex == 3) FocusScope.of(context).unfocus();
                },
              ),
            );
          },
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
        final isEnabled = timerState.maybeMap(
          idle: (_) => true,
          orElse: () => false,
        );

        return TextButton(
          onPressed: isEnabled
              ? () {
                  _sendCodeBloc.add(
                    SendCodeEvent.sendCodeRequested(phoneNumber: widget.phoneNumber),
                  );
                  _codeTimerBloc.add(const CodeTimerEvent.started());
                }
              : null,
          child: Text(
            context.l10n.callAgain,
            style: context.uiFonts.text16Medium.copyWith(
              color: isEnabled ? context.uiColors.orangePrimary : context.uiColors.black40,
            ),
          ),
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
    return BlocBuilder<CodeTimerBloc, CodeTimerState>(
      bloc: _codeTimerBloc,
      builder: (context, state) {
        if (state.secondsRemaining > 0) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: context.uiColors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: context.uiColors.brown),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    color: context.uiColors.orangePrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _formatTime(state.secondsRemaining),
                    style: context.uiFonts.text16Semibold,
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
