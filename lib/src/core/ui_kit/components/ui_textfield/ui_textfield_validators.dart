import 'package:collection/collection.dart';

extension ValidatorExtension on List<UiTextFieldValidator> {
  bool hasValidationMessage(String? value) {
    return any((validator) => validator.getValidationMessage(value) != null);
  }

  String? getFirstValidationMessage(String? value) {
    final UiTextFieldValidator? firstNotEmptyValidator = firstWhereOrNull(
      (validator) => validator.getValidationMessage(value) != null,
    );

    return firstNotEmptyValidator?.getValidationMessage(value);
  }
}

abstract class UiTextFieldValidator {
  final String validationMessage;

  const UiTextFieldValidator({required this.validationMessage});

  String? getValidationMessage(String? value);
}

class RequiredFieldValidator extends UiTextFieldValidator {
  const RequiredFieldValidator({required super.validationMessage});

  @override
  String? getValidationMessage(String? value) {
    if (value == null || value.isEmpty) {
      return validationMessage;
    }

    return null;
  }
}

class DateFieldValidator extends UiTextFieldValidator {
  final String dateInputMask;

  const DateFieldValidator({required this.dateInputMask, required super.validationMessage});

  @override
  String? getValidationMessage(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final isDateHasCorrectFormat = RegExp(r'^\d\d\.\d\d\.\d\d\d\d$').hasMatch(value);

    if (!isDateHasCorrectFormat) {
      return validationMessage;
    }

    if (value.length != dateInputMask.length) {
      return validationMessage;
    }

    final List<String> date = value.split('.');

    final day = int.parse(date[0]);
    final month = int.parse(date[1]);
    final year = int.parse(date[2]);

    final bool isErrorInFebraury = _isErrorInFebruary(day: day, month: month, year: year);

    if (isErrorInFebraury) {
      return validationMessage;
    }

    final isCountOfDaysMoreThanMonthLimit = _isMonthLong(month: month) ? day > 31 : day > 30;

    final isDayNotValid = day <= 0 || isCountOfDaysMoreThanMonthLimit;

    final bool isMonthNotValid = _isMonthNotValid(month: month);

    if (isDayNotValid || isMonthNotValid) {
      return validationMessage;
    }

    return null;
  }

  /// Високосным годом является тот год, который нацело делится на 4,
  /// кроме столетий (исключением являются столетия делящиеся на 400).
  bool _isLeapYear({required int year}) {
    return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
  }

  bool _isErrorInFebruary({required int day, required int month, required int year}) {
    return month == 2 && (_isLeapYear(year: year) ? day > 29 : day > 28);
  }

  bool _isMonthLong({required int month}) {
    final thirtyOneDays = [1, 3, 5, 7, 8, 10, 12];

    return thirtyOneDays.contains(month);
  }

  bool _isMonthNotValid({required int month}) {
    return month > 12 || month <= 0;
  }
}

class DateNotOnTheFutureValidator extends UiTextFieldValidator {
  const DateNotOnTheFutureValidator({required super.validationMessage});

  @override
  String? getValidationMessage(String? value) {
    if (value == null) {
      return null;
    }

    final List<String> date = value.split('.');

    final bool isInputDateAfterCurrentDate = DateTime.parse(
      date.reversed.join('-'),
    ).isAfter(DateTime.now());

    if (isInputDateAfterCurrentDate) {
      return validationMessage;
    }

    return null;
  }
}

class DateNoLaterThenValidator extends UiTextFieldValidator {
  final DateTime minimalDate;

  const DateNoLaterThenValidator({required super.validationMessage, required this.minimalDate});

  @override
  String? getValidationMessage(String? value) {
    if (value == null) {
      return null;
    }

    final List<String> date = value.split('.');

    final bool isInputDateBeforeMinimalDate = DateTime.parse(
      date.reversed.join('-'),
    ).isBefore(minimalDate);

    if (isInputDateBeforeMinimalDate) {
      return validationMessage;
    }

    return null;
  }
}

class MaxLengthValidator extends UiTextFieldValidator {
  final int maxLength;

  const MaxLengthValidator({required super.validationMessage, required this.maxLength});

  @override
  String? getValidationMessage(String? value) {
    if (value == null) {
      return null;
    }

    if (value.length > maxLength) {
      return validationMessage;
    }

    return null;
  }
}

class MinLengthValidator extends UiTextFieldValidator {
  final int minLength;

  const MinLengthValidator({required super.validationMessage, required this.minLength});

  @override
  String? getValidationMessage(String? value) {
    if (value == null) {
      return null;
    }

    if (value.length < minLength) {
      return validationMessage;
    }

    return null;
  }
}
