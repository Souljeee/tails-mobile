part of 'auth_bloc.dart';

typedef AuthEventMatch<T, S extends AuthEvent> = T Function(S event);

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  const factory AuthEvent.login({
    required String phoneNumber,
    required String code,
  }) = AuthEvent$Login;

  const factory AuthEvent.authorizationStatusUpdated({
    required AuthorizationStatus newStatus,
  }) = AuthEvent$AuthorizationStatusUpdated;

  const factory AuthEvent.logout() = AuthEvent$Logout;

  const factory AuthEvent.accountDeleted() = AuthEvent$AccountDeleted;

  T map<T>({
    required AuthEventMatch<T, AuthEvent$Login> login,
    required AuthEventMatch<T, AuthEvent$AuthorizationStatusUpdated> authorizationStatusUpdated,
    required AuthEventMatch<T, AuthEvent$Logout> logout,
    required AuthEventMatch<T, AuthEvent$AccountDeleted> accountDeleted,
  }) =>
      switch (this) {
        final AuthEvent$Login event => login(event),
        final AuthEvent$AuthorizationStatusUpdated event => authorizationStatusUpdated(event),
        final AuthEvent$Logout event => logout(event),
        final AuthEvent$AccountDeleted event => accountDeleted(event),
      };
}

final class AuthEvent$AuthorizationStatusUpdated extends AuthEvent {
  final AuthorizationStatus newStatus;

  const AuthEvent$AuthorizationStatusUpdated({
    required this.newStatus,
  });

  @override
  List<Object?> get props => [
        newStatus,
      ];
}

final class AuthEvent$Logout extends AuthEvent {
  const AuthEvent$Logout();

  @override
  List<Object?> get props => [];
}

final class AuthEvent$Login extends AuthEvent {
  final String phoneNumber;
  final String code;

  const AuthEvent$Login({
    required this.phoneNumber,
    required this.code,
  });

  @override
  List<Object?> get props => [
        phoneNumber,
        code,
      ];
}

/// Сервер удалил аккаунт и закрыл все сессии: остаётся забыть токены на устройстве.
final class AuthEvent$AccountDeleted extends AuthEvent {
  const AuthEvent$AccountDeleted();

  @override
  List<Object?> get props => [];
}
