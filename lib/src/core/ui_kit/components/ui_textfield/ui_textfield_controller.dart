import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_validators.dart';

class UiTextFieldController extends TextEditingController {
  final List<UiTextFieldValidator> validators;

  UiTextFieldController({super.text, this.validators = const []});

  bool get isValid => !validators.hasValidationMessage(text);
}
