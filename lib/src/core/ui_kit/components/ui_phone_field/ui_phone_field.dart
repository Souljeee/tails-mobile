import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Поле номера телефона: флаг, код страны, разделитель и цифры моноширинным шрифтом.
///
/// В контроллер попадает номер без кода страны в формате `### ###-##-##`.
class UiPhoneField extends StatelessWidget {
  const UiPhoneField({
    required this.controller,
    required this.countryFlag,
    this.countryCode = '+7',
    this.labelText,
    this.placeholderText,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.textInputAction,
    super.key,
  });

  static const String inputMask = '### ###-##-##';

  final UiTextFieldController controller;

  /// Флаг страны 24 pt по ширине.
  final Widget countryFlag;
  final String countryCode;
  final String? labelText;
  final String? placeholderText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final digitsStyle = context.uiFonts.monoDigits.copyWith(fontSize: 18);

    return UiTextField(
      controller: controller,
      labelText: labelText,
      placeholderText: placeholderText,
      keyboardType: TextInputType.phone,
      inputMask: inputMask,
      inputFilter: {'#': RegExp(r'\d')},
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      focusNode: focusNode,
      autofocus: autofocus,
      textInputAction: textInputAction,
      inputTextStyle: digitsStyle.copyWith(color: palette.ink),
      placeholderStyle: digitsStyle.copyWith(color: palette.ink3),
      trailingConstraints: const BoxConstraints(),
      trailingIcon: Padding(
        padding: const EdgeInsets.only(left: UiSpacing.x3, right: UiSpacing.x3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 24, child: countryFlag),
            const SizedBox(width: UiSpacing.x2),
            Text(countryCode, style: digitsStyle.copyWith(color: palette.ink)),
            const SizedBox(width: UiSpacing.x3),
            SizedBox(
              height: 24,
              child: VerticalDivider(width: 1, thickness: 1, color: palette.line),
            ),
          ],
        ),
      ),
    );
  }
}
