import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_validators.dart';

class UiTextFieldController extends TextEditingController {
  final List<UiTextFieldValidator> validators;
  
  /// Флаг, указывающий, было ли взаимодействие с полем
  bool _touched = false;
  
  bool get touched => _touched;

  UiTextFieldController({super.text, this.validators = const []});

  /// Помечает поле как "тронутое" (пользователь начал взаимодействие)
  void markAsTouched() {
    if (!_touched) {
      _touched = true;
      notifyListeners();
    }
  }
  
  /// Сбрасывает состояние "тронутости"
  void resetTouched() {
    if (_touched) {
      _touched = false;
      notifyListeners();
    }
  }

  bool get isValid => !validators.hasValidationMessage(text);
}
