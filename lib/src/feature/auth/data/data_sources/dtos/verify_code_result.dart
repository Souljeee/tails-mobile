import 'package:equatable/equatable.dart';
import 'package:rest_client/rest_client.dart';

/// Результат подтверждения кода: токены и сведения о пользователе.
class VerifyCodeResult extends Equatable {
  const VerifyCodeResult({required this.token, this.isNewUser, this.userId});

  /// Токены сессии.
  final OAuth2Token token;

  /// Первая ли это успешная верификация номера; `null`, если бэкенд не сообщил.
  final bool? isNewUser;

  /// Внутренний идентификатор пользователя; `null`, если бэкенд не сообщил.
  final String? userId;

  @override
  List<Object?> get props => [token, isNewUser, userId];
}
