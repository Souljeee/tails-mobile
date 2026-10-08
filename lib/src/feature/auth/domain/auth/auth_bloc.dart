import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/analytics/analytics_reason_mapper.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/logging/tails_loggable.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/dtos/verify_code_result.dart';
import 'package:tails_mobile/src/feature/auth/data/repositories/auth_repository.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/account_blocked_exception.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/invalid_code_exception.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  /// Выход или удаление аккаунта начаты самим пользователем: потеря сессии после них
  /// ожидаема и не считается истечением сессии.
  bool _signOutRequested = false;

  AuthBloc(super.initialState, {required AuthRepository authRepository})
    : _authRepository = authRepository {
    on<AuthEvent>(
      (event, emit) => event.map(
        login: (event) => _onLogin(event, emit),
        authorizationStatusUpdated: (event) => _onAuthorizationStatusUpdated(event, emit),
        logout: (event) => _onLogout(event, emit),
        accountDeleted: (event) => _onAccountDeleted(event, emit),
      ),
    );

    _authRepository.authorizationStatus.listen((authorizationStatus) {
      add(AuthEvent.authorizationStatusUpdated(newStatus: authorizationStatus));
    });
  }

  Future<void> _onLogin(AuthEvent$Login event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.processing(status: state.status));

      final result = await _authRepository.verifyCode(
        code: event.code,
        phoneNumber: event.phoneNumber,
      );

      _reportLogin(result);

      emit(const AuthState.idle(status: AuthorizationStatus.authorized));
    } catch (e, s) {
      addError(e, s);
      TailsAnalytics.log(
        TailsAnalyticsEvents.loginFailed(switch (e) {
          InvalidCodeException() => AnalyticsReason.invalidCode,
          AccountBlockedException() => AnalyticsReason.unauthorized,
          _ => analyticsReasonOf(e),
        }),
      );

      emit(AuthState.error(status: state.status));
      emit(AuthState.idle(status: state.status));
    }
  }

  Future<void> _onAuthorizationStatusUpdated(
    AuthEvent$AuthorizationStatusUpdated event,
    Emitter<AuthState> emit,
  ) async {
    // Сессия пропала без выхода пользователя: токены отозваны или истекли.
    if (event.newStatus == AuthorizationStatus.notAuthorized) {
      if (state.status == AuthorizationStatus.authorized && !_signOutRequested) {
        TailsAnalytics.log(TailsAnalyticsEvents.sessionExpired);
        TailsAnalytics.clearUser();
      }
      _signOutRequested = false;
    }

    emit(AuthState.idle(status: event.newStatus));
  }

  Future<void> _onLogout(AuthEvent$Logout event, Emitter<AuthState> emit) async {
    try {
      emit(AuthState.processing(status: state.status));

      await _authRepository.logout();

      _reportLogout();

      emit(const AuthState.idle(status: AuthorizationStatus.notAuthorized));
    } catch (e, s) {
      addError(e, s);

      emit(AuthState.error(status: state.status));
      emit(AuthState.idle(status: state.status));
    }
  }

  Future<void> _onAccountDeleted(AuthEvent$AccountDeleted event, Emitter<AuthState> emit) async {
    _signOutRequested = true;
    try {
      await _authRepository.clearSession();
    } catch (e, s) {
      addError(e, s);
    }
    TailsAnalytics.clearUser();
  }

  /// Привязывает аналитику к пользователю и отправляет события входа и регистрации.
  void _reportLogin(VerifyCodeResult result) {
    if (result.userId case final userId? when userId.isNotEmpty) {
      TailsAnalytics.setUser(userId);
    }

    TailsAnalytics.log(TailsAnalyticsEvents.loginSucceeded(isNewUser: result.isNewUser));
    if (result.isNewUser ?? false) {
      TailsAnalytics.log(TailsAnalyticsEvents.signupCompleted);
      TailsAnalytics.setUserProperty(
        TailsAnalyticsUserProperty.signupDate,
        _formatDate(DateTime.now()),
      );
    }
  }

  /// Событие выхода уходит до сброса пользователя, чтобы попасть в его историю.
  void _reportLogout() {
    TailsAnalytics.log(TailsAnalyticsEvents.logout);
    TailsAnalytics.clearUser();
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
