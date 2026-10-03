/// Код для удаления аккаунта запрошен слишком рано: повторить можно через минуту.
class DeletionCodeTooSoonException implements Exception {
  const DeletionCodeTooSoonException();
}

/// Код для удаления аккаунта неверен, просрочен или попытки закончились.
///
/// [message] — текст от сервера на русском, его можно показать пользователю.
class InvalidDeletionCodeException implements Exception {
  const InvalidDeletionCodeException({required this.message});

  final String message;
}

/// Слишком много обращений подряд.
class FeedbackRateLimitException implements Exception {
  const FeedbackRateLimitException();
}

/// Сервер отклонил данные профиля (например, слишком длинное имя или битое фото).
class ProfileValidationException implements Exception {
  const ProfileValidationException({this.message});

  /// Сообщение сервера, если оно есть.
  final String? message;
}
