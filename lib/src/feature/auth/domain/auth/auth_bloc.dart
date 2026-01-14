import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/auth/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(
    super.initialState, {
    required AuthRepository authRepository,
  }) : _authRepository = authRepository {
    on<AuthEvent>(
      (event, emit) => event.map(
        login: (event) => _onLogin(event, emit),
        authorizationStatusUpdated: (event) => _onAuthorizationStatusUpdated(event, emit),
      ),
    );

    _authRepository.authorizationStatus.listen(
      (authorizationStatus) {
        add(AuthEvent.authorizationStatusUpdated(newStatus: authorizationStatus));
      },
    );
  }

  Future<void> _onLogin(
    AuthEvent$Login event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthState.processing(status: state.status));

      await _authRepository.verifyCode(
        code: event.code,
        phoneNumber: event.phoneNumber,
      );

      emit(const AuthState.idle(status: AuthorizationStatus.authorized));
    } catch (e, s) {
      addError(e, s);

      emit(AuthState.error(status: state.status));
      emit(AuthState.idle(status: state.status));
    }
  }

  Future<void> _onAuthorizationStatusUpdated(
    AuthEvent$AuthorizationStatusUpdated event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.idle(status: event.newStatus));
  }
}
