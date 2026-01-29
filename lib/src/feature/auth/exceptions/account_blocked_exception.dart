/// {@template account_blocked_exception}
/// Exception thrown when the account is blocked.
/// {@endtemplate}
class AccountBlockedException implements Exception {
  /// {@macro account_blocked_exception}
  final String phoneNumber;

  /// {@macro account_blocked_exception}
  const AccountBlockedException({required this.phoneNumber});

  @override
  String toString() => 'Аккаунт заблокирован для номера телефона: $phoneNumber';
}
