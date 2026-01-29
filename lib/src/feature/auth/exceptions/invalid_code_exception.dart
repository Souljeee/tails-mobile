/// {@template invalid_code_exception}
/// Exception thrown when the code is invalid.
/// {@endtemplate}
class InvalidCodeException implements Exception {
  /// {@macro invalid_code_exception}
  final String code;
  final String phoneNumber;

  /// {@macro invalid_code_exception}
  const InvalidCodeException({
    required this.code,
    required this.phoneNumber,
  });

  @override
  String toString() => 'Некорректный код: $code для номера телефона: $phoneNumber';
}
