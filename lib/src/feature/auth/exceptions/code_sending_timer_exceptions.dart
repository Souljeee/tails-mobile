/// {@template code_sending_timer_exception}
/// Exception thrown when the code sending timer is not started.
/// {@endtemplate}
class CodeSendingTimerException implements Exception {
  /// {@macro code_sending_timer_exception}
  const CodeSendingTimerException();

  /// {@macro code_sending_timer_exception}
  @override
  String toString() => 'Код уже отправлен. Попробуйте через 1 минуту.';
}
