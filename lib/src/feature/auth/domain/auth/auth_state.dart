part of 'auth_bloc.dart';

typedef AuthStateMatch<T, S extends AuthState> = T Function(S state);

sealed class AuthState extends Equatable {
  final AuthorizationStatus status;

  const AuthState({
    required this.status,
  });

  const factory AuthState.idle({
    required AuthorizationStatus status,
  }) = AuthState$Idle;

  const factory AuthState.processing({
    required AuthorizationStatus status,
  }) = AuthState$Processing;

  const factory AuthState.error({
    required AuthorizationStatus status,
  }) = AuthState$Error;

  T map<T>({
    required AuthStateMatch<T, AuthState$Idle> idle,
    required AuthStateMatch<T, AuthState$Processing> processing,
    required AuthStateMatch<T, AuthState$Error> error,
  }) =>
      switch (this) {
        final AuthState$Idle state => idle(state),
        final AuthState$Processing state => processing(state),
        final AuthState$Error state => error(state),
      };
  T? mapOrNull<T>({
    AuthStateMatch<T, AuthState$Idle>? idle,
    AuthStateMatch<T, AuthState$Processing>? processing,
    AuthStateMatch<T, AuthState$Error>? error,
  }) =>
      map<T?>(
        idle: idle ?? (_) => null,
        processing: processing ?? (_) => null,
        error: error ?? (_) => null,
      );
            
  T maybeMap<T>({
    required T Function() orElse,
    AuthStateMatch<T, AuthState$Idle>? idle,
    AuthStateMatch<T, AuthState$Processing>? processing,
    AuthStateMatch<T, AuthState$Error>? error,
  }) =>
      map<T>(
        idle: idle ?? (_) => orElse(),
        processing: processing ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class AuthState$Idle extends AuthState {
  const AuthState$Idle({required super.status});

  @override
  List<Object?> get props => [status];
}

final class AuthState$Processing extends AuthState {
  const AuthState$Processing({required super.status});

  @override
  List<Object?> get props => [status];
}

final class AuthState$Error extends AuthState {
  const AuthState$Error({required super.status});

  @override
  List<Object?> get props => [status];
}
