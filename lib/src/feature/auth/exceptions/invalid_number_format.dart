/// {@template invalid_number_format_exception}
/// Exception thrown when the phone number format is invalid.
/// {@endtemplate}
class InvalidPhoneNumberFormatException implements Exception {
  /// {@macro invalid_number_format_exception}
  final String phoneNumber;

  /// {@macro invalid_number_format_exception}
  const InvalidPhoneNumberFormatException({required this.phoneNumber});

  @override
  String toString() => 'Некорректный формат номера телефона: $phoneNumber';
}
