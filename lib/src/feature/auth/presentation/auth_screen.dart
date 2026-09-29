import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_hero_carousel/ui_hero_carousel.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_phone_field/ui_phone_field.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/auth/domain/code_timer/code_timer_bloc.dart';
import 'package:tails_mobile/src/feature/auth/domain/send_code/send_code_bloc.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  /// Доля высоты экрана под фото-карусель.
  static const double _heroHeightFactor = 0.45;

  @override
  Widget build(BuildContext context) {
    final heroHeight = (MediaQuery.sizeOf(context).height * _heroHeightFactor).clamp(240.0, 420.0);

    return Scaffold(
      backgroundColor: context.uiPalette.canvas,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Отступ до текста согласия равен оставшейся высоте (аналог Spacer),
            // а при открытой клавиатуре экран прокручивается.
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: heroHeight, child: const _OnboardingSlides()),
                        const SizedBox(height: UiSpacing.x6),
                        const _LoginForm(),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: UiSpacing.x5,
                        vertical: UiSpacing.x4,
                      ),
                      child: _PrivacyTerms(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingSlides extends StatelessWidget {
  const _OnboardingSlides();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final images = context.uiImages;

    return UiHeroCarousel(
      slides: [
        UiHeroSlide(
          image: AssetImage(images.onboardingSlide1.path),
          title: l10n.authSlide1Title,
          subtitle: l10n.authSlide1Subtitle,
        ),
        UiHeroSlide(
          image: AssetImage(images.onboardingSlode2.path),
          title: l10n.authSlide2Title,
          subtitle: l10n.authSlide2Subtitle,
        ),
        UiHeroSlide(
          image: AssetImage(images.onboardigSlide3.path),
          title: l10n.authSlide3Title,
          subtitle: l10n.authSlide3Subtitle,
        ),
      ],
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  static const String _countryCode = '+7';
  static const int _nationalNumberLength = 10;

  late final _numberController = UiTextFieldController();
  final _focusNode = FocusNode();

  late final SendCodeBloc _sendCodeBloc;
  late final CodeTimerBloc _codeTimerBloc;

  /// Только цифры номера без кода страны.
  String get _digits => _numberController.text.replaceAll(RegExp(r'\D'), '');

  /// Номер в формате `+79990000000`.
  String get _phoneNumber => '$_countryCode$_digits';

  bool get _isNumberValid => _digits.length == _nationalNumberLength;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final dependencies = DependenciesScope.of(context);
    _sendCodeBloc = SendCodeBloc(authRepository: dependencies.authRepository);
    _codeTimerBloc = dependencies.codeTimerBloc;
  }

  @override
  void dispose() {
    _numberController.dispose();
    _focusNode.dispose();
    _sendCodeBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.authPhoneTitle, style: fonts.displayM.copyWith(color: palette.ink)),
          const SizedBox(height: UiSpacing.x2),
          Text(l10n.authPhoneSubtitle, style: fonts.body.copyWith(color: palette.ink2)),
          const SizedBox(height: UiSpacing.x5),
          TapRegion(
            onTapOutside: (_) => _focusNode.unfocus(),
            child: UiPhoneField(
              focusNode: _focusNode,
              controller: _numberController,
              labelText: l10n.authPhoneLabel,
              placeholderText: '999 000-00-00',
              textInputAction: TextInputAction.done,
              countryFlag: UiSvgImage(svgPath: context.uiIcons.russiaFlag.path, height: 16),
            ),
          ),
          const SizedBox(height: UiSpacing.x6),
          BlocConsumer<SendCodeBloc, SendCodeState>(
            bloc: _sendCodeBloc,
            listener: (context, state) {
              state.mapOrNull(
                success: (_) {
                  // Запускаем таймер и переходим на экран ввода кода
                  _codeTimerBloc.add(const CodeTimerEvent.started());
                  EnterCodeRoute(phoneNumber: _phoneNumber).push<void>(context);
                },
                error: (_) => showUiSnackBar(context, message: l10n.tryLater),
              );
            },
            builder: (context, sendCodeState) {
              return BlocBuilder<CodeTimerBloc, CodeTimerState>(
                bloc: _codeTimerBloc,
                builder: (context, timerState) {
                  return ValueListenableBuilder(
                    valueListenable: _numberController,
                    builder: (context, value, child) {
                      final isTimerActive = timerState.maybeMap(
                        ticking: (_) => true,
                        orElse: () => false,
                      );

                      return SizedBox(
                        width: double.infinity,
                        child: UiButton.main(
                          isLoading: sendCodeState.maybeMap(
                            loading: (_) => true,
                            orElse: () => false,
                          ),
                          onPressed: _isNumberValid
                              ? isTimerActive
                                    ? _navigateToEnterCode
                                    : _sendCode
                              : null,
                          icon: Icons.arrow_right_alt,
                          label: l10n.authGetCode,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _navigateToEnterCode() {
    EnterCodeRoute(phoneNumber: _phoneNumber).push<void>(context);
  }

  void _sendCode() {
    _sendCodeBloc.add(SendCodeEvent$SendCodeRequested(phoneNumber: _phoneNumber));
  }
}

class _PrivacyTerms extends StatelessWidget {
  const _PrivacyTerms();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final base = context.uiFonts.footnote.copyWith(color: context.uiPalette.ink3);
    final link = base.copyWith(decoration: TextDecoration.underline);

    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        style: base,
        children: [
          TextSpan(text: l10n.authConsentPrefix),
          TextSpan(text: l10n.authTerms, style: link),
          TextSpan(text: l10n.authConsentAnd),
          TextSpan(text: l10n.authPrivacy, style: link),
        ],
      ),
    );
  }
}
