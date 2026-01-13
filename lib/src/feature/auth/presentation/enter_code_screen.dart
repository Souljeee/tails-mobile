import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

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
        child: Column(
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
              onCompleted: (code) {},
            ),
            const Spacer(),
            const _RetryTimer(),
            const SizedBox(height: 12),
            _RetryButton(onTap: () {}),
          ],
        ),
      ),
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

class _RetryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RetryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        context.l10n.callAgain,
        style: context.uiFonts.text16Medium.copyWith(color: context.uiColors.black40),
      ),
    );
  }
}

class _RetryTimer extends StatelessWidget {
  const _RetryTimer();

  @override
  Widget build(BuildContext context) {
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
              '0:34',
              style: context.uiFonts.text16Semibold,
            ),
          ],
        ),
      ),
    );
  }
}
