/// {@template invalid_or_expired_token_exception}
/// Exception thrown when a token is invalid or expired
/// {@endtemplate}
class InvalidOrExpiredTokenException implements Exception {
  /// {@macro invalid_or_expired_token_exception}
  final String token;

  /// {@macro invalid_or_expired_token_exception}
  const InvalidOrExpiredTokenException({required this.token});

  @override
  String toString() => 'Токен $token не валиден или просрочен';
}
