import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_validators.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/auth/domain/send_code/send_code_bloc.dart';
import 'package:tails_mobile/src/feature/auth/presentation/models/slide_uio.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            /// Вся эта структура необходима, чтобы до секции условиями использования
            /// был отступ равный всей оставлшейся высоте (аналог Spacer)
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: const [
                        _OnboardingSlides(),
                        SizedBox(height: 28),
                        _LoginForm(),
                        SizedBox(height: 8),
                      ],
                    ),
                    const Center(
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

class _OnboardingSlides extends StatefulWidget {
  const _OnboardingSlides();

  @override
  State<_OnboardingSlides> createState() => _OnboardingSlidesState();
}

class _OnboardingSlidesState extends State<_OnboardingSlides> {
  late final _slides = [
    SlideUio(
      imagePath: context.uiImages.onboardingSlide1.path,
      title: 'Профиль любимца',
      subtitle: 'Имя, порода, дата рождения и заметки — чтобы ничего не терялось.',
    ),
    SlideUio(
      imagePath: context.uiImages.onboardingSlode2.path,
      title: 'Календарь питомца',
      subtitle: 'Все запланированные события в одном списке и по датам.',
    ),
    SlideUio(
      imagePath: context.uiImages.onboardigSlide3.path,
      title: 'Ничего не забыть',
      subtitle: 'Создавайте напоминания о важных делах для питомца за пару секунд.',
    ),
  ];

  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      width: MediaQuery.sizeOf(context).width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            physics: const ClampingScrollPhysics(),
            controller: _pageController,
            itemCount: _slides.length,
            itemBuilder: (context, index) => _Slide(slide: _slides[index]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: _slides.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: context.uiColors.orangePrimary,
                  dotColor: context.uiColors.lightOrange,
                  dotHeight: 8,
                  dotWidth: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final SlideUio slide;

  const _Slide({required this.slide});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadiusGeometry.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              slide.imagePath,
              height: MediaQuery.sizeOf(context).height * 0.6,
              width: MediaQuery.sizeOf(context).width,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    context.uiColors.white,
                    Colors.transparent,
                  ],
                  stops: const [0.01, 0.7],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: Column(
              children: [
                Text(
                  slide.title,
                  style: context.uiFonts.header28Semibold.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  slide.subtitle,
                  style: context.uiFonts.text16Regular.copyWith(color: context.uiColors.brown),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final String _numberInputMask = '(###)###-##-##';
  final String _countryCode = '+7';
  late final _numberController = UiTextFieldController(
    validators: [
      const RequiredFieldValidator(validationMessage: ''),
    ],
  );
  final _focusNode = FocusNode();

  late final SendCodeBloc _sendCodeBloc =
      SendCodeBloc(authRepository: DependenciesScope.of(context).authRepository);

  String get _phoneNumber => '$_countryCode${_numberController.text}';

  @override
  void dispose() {
    _numberController.dispose();
    _focusNode.dispose();
    _sendCodeBloc.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Введите ваш номер телефона',
            style: context.uiFonts.header20Medium.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Мы отправим вам безопасный код подтверждения',
            style: context.uiFonts.text14Regular.copyWith(
              color: context.uiColors.brown,
            ),
          ),
          const SizedBox(height: 12),
          TapRegion(
            onTapOutside: (_) {
              _focusNode.unfocus();
            },
            child: UiTextField(
              focusNode: _focusNode,
              controller: _numberController,
              inputMask: _numberInputMask,
              inputFilter: {'#': RegExp('[0-9]')},
              inputTextStyle: context.uiFonts.header20Medium,
              fillColor: context.uiColors.white,
              placeholderText: '(999)000-00-00',
              alwaysShowBorder: true,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              placeholderStyle: context.uiFonts.header20Medium
                  .copyWith(color: context.uiColors.brown.withValues(alpha: 0.5)),
              trailingIcon: const _CountryCode(),
            ),
          ),
          const SizedBox(height: 24),
          BlocConsumer<SendCodeBloc, SendCodeState>(
            bloc: _sendCodeBloc,
            listener: (context, state) {
              state.mapOrNull(
                success: (_) => EnterCodeRoute(phoneNumber: _phoneNumber).push<void>(context),
                error: (_) => _showErrorSnackBar,
              );
            },
            builder: (context, state) {
              return ValueListenableBuilder(
                  valueListenable: _numberController,
                  builder: (context, value, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: UiButton.main(
                        isLoading: state.maybeMap(
                          loading: (_) => true,
                          orElse: () => false,
                        ),
                        onPressed: _numberController.isValid &&
                                _phoneNumber.length == _numberInputMask.length + _countryCode.length
                            ? _sendCode
                            : null,
                        icon: Icons.arrow_right_alt,
                        label: 'Войти',
                      ),
                    );
                  });
            },
          ),
        ],
      ),
    );
  }

  void _sendCode() {
    final formattedPhoneNumber =
        _phoneNumber.replaceAll('(', '').replaceAll(')', '').replaceAll('-', '');

    _sendCodeBloc.add(SendCodeEvent$SendCodeRequested(phoneNumber: formattedPhoneNumber));
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Произошла ошибка. Повторите позднее.',
          style: context.uiFonts.text14Regular.copyWith(color: context.uiColors.white),
        ),
        backgroundColor: context.uiColors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _PrivacyTerms extends StatelessWidget {
  const _PrivacyTerms();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Нажимая «Войти», вы ссоглашаетесь с нашими\n',
            style: context.uiFonts.text12Regular.copyWith(color: context.uiColors.brown),
          ),
          TextSpan(
            text: 'Условиями использования ',
            style: context.uiFonts.text12Regular.copyWith(
              color: context.uiColors.brown,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(
            text: 'и ',
            style: context.uiFonts.text12Regular.copyWith(color: context.uiColors.brown),
          ),
          TextSpan(
            text: 'Политикой\nконфиденциальности',
            style: context.uiFonts.text12Regular.copyWith(
              color: context.uiColors.brown,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryCode extends StatelessWidget {
  const _CountryCode();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          UiSvgImage(
            svgPath: context.uiIcons.russiaFlag.path,
            height: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '+7',
            style: context.uiFonts.header20Medium,
          ),
          const SizedBox(width: 8),
          VerticalDivider(
            color: context.uiColors.brown,
            thickness: 1,
            width: 1,
          )
        ],
      ),
    );
  }
}
