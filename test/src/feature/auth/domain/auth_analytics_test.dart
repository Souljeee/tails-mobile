import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/dtos/verify_code_result.dart';
import 'package:tails_mobile/src/feature/auth/data/repositories/auth_repository.dart';
import 'package:tails_mobile/src/feature/auth/domain/auth/auth_bloc.dart';
import 'package:tails_mobile/src/feature/auth/domain/send_code/send_code_bloc.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/code_sending_timer_exceptions.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/invalid_code_exception.dart';

import '../../../../helpers/recording_analytics_sink.dart';

final class _FakeAuthRepository extends Fake implements AuthRepository {
  VerifyCodeResult? result;
  Exception? verifyError;
  Exception? sendError;

  // ignore: close_sinks
  final statuses = StreamController<AuthorizationStatus>.broadcast();

  @override
  Stream<AuthorizationStatus> get authorizationStatus => statuses.stream;

  @override
  Future<VerifyCodeResult> verifyCode({required String code, required String phoneNumber}) async {
    if (verifyError != null) throw verifyError!;

    return result!;
  }

  @override
  Future<void> sendCode({required String phoneNumber}) async {
    if (sendError != null) throw sendError!;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> clearSession() async {}
}

const _token = OAuth2Token(
  accessToken: 'a',
  refreshToken: 'r',
  accessExpires: 1,
  refreshExpires: 2,
);

Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 50));

void main() {
  late RecordingAnalyticsSink sink;
  late _FakeAuthRepository repository;

  setUp(() {
    sink = RecordingAnalyticsSink();
    TailsAnalytics.configure(sinks: [sink]);
    repository = _FakeAuthRepository();
  });

  tearDown(TailsAnalytics.reset);

  group('AuthBloc', () {
    late AuthBloc bloc;

    setUp(() {
      bloc = AuthBloc(
        const AuthState.idle(status: AuthorizationStatus.notAuthorized),
        authRepository: repository,
      );
    });

    tearDown(() => bloc.close());

    test('новый пользователь: login_succeeded, signup_completed, setUser, signup_date', () async {
      repository.result = const VerifyCodeResult(token: _token, isNewUser: true, userId: 'u1');

      bloc.add(const AuthEvent.login(phoneNumber: '+79990000000', code: '1234'));
      await _pump();

      expect(sink.names, ['login_succeeded', 'signup_completed']);
      expect(sink.events.first.parameters, {'is_new_user': true});
      expect(sink.userIds, ['u1']);
      expect(
        sink.properties[TailsAnalyticsUserProperty.signupDate],
        matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')),
      );
    });

    test('повторный вход: без signup_completed', () async {
      repository.result = const VerifyCodeResult(token: _token, isNewUser: false, userId: 'u1');

      bloc.add(const AuthEvent.login(phoneNumber: '+79990000000', code: '1234'));
      await _pump();

      expect(sink.names, ['login_succeeded']);
      expect(sink.events.single.parameters, {'is_new_user': false});
    });

    test('старый бэкенд: признак неизвестен, пользователь не привязывается', () async {
      repository.result = const VerifyCodeResult(token: _token);

      bloc.add(const AuthEvent.login(phoneNumber: '+79990000000', code: '1234'));
      await _pump();

      expect(sink.names, ['login_succeeded']);
      expect(sink.events.single.parameters, isEmpty);
      expect(sink.userIds, isEmpty);
    });

    test('неверный код: login_failed с причиной invalid_code', () async {
      repository.verifyError = const InvalidCodeException(code: '0000', phoneNumber: '+7999');

      bloc.add(const AuthEvent.login(phoneNumber: '+79990000000', code: '0000'));
      await _pump();

      expect(sink.names, ['login_failed']);
      expect(sink.events.single.parameters, {'reason': 'invalid_code'});
      expect(sink.userIds, isEmpty);
    });

    test('выход: logout и сброс пользователя', () async {
      bloc.add(const AuthEvent.logout());
      await _pump();

      expect(sink.names, ['logout']);
      expect(sink.userIds, [null]);
    });

    test('удаление аккаунта сбрасывает пользователя', () async {
      bloc.add(const AuthEvent.accountDeleted());
      await _pump();

      expect(sink.userIds, [null]);
    });

    test('сессия пропала сама: session_expired и сброс пользователя', () async {
      final authorized = AuthBloc(
        const AuthState.idle(status: AuthorizationStatus.authorized),
        authRepository: repository,
      );
      addTearDown(authorized.close);

      repository.statuses.add(AuthorizationStatus.notAuthorized);
      await _pump();

      expect(sink.names, ['session_expired']);
      expect(sink.userIds, [null]);
    });

    test('выход пользователя не считается истечением сессии', () async {
      final authorized = AuthBloc(
        const AuthState.idle(status: AuthorizationStatus.authorized),
        authRepository: repository,
      );
      addTearDown(authorized.close);

      authorized.add(const AuthEvent.logout());
      await _pump();
      repository.statuses.add(AuthorizationStatus.notAuthorized);
      await _pump();

      expect(sink.names, ['logout']);
    });

    test('в параметры не попадают телефон и код', () async {
      repository.result = const VerifyCodeResult(token: _token, isNewUser: true, userId: 'u1');

      bloc.add(const AuthEvent.login(phoneNumber: '+79990000000', code: '1234'));
      await _pump();

      final text = sink.events.map((e) => '$e').join();
      expect(text, isNot(contains('9990000000')));
      expect(text, isNot(contains('1234')));
    });
  });

  group('SendCodeBloc', () {
    late SendCodeBloc bloc;

    setUp(() => bloc = SendCodeBloc(authRepository: repository));
    tearDown(() => bloc.close());

    test('код запрошен: is_resend передаётся', () async {
      bloc
        ..add(const SendCodeEvent.sendCodeRequested(phoneNumber: '+7999'))
        ..add(const SendCodeEvent.sendCodeRequested(phoneNumber: '+7999', isResend: true));
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(sink.names, ['login_code_requested', 'login_code_requested']);
      expect(sink.events[0].parameters, {'is_resend': false});
      expect(sink.events[1].parameters, {'is_resend': true});
    });

    test('слишком частые запросы: rate_limited', () async {
      repository.sendError = const CodeSendingTimerException();

      bloc.add(const SendCodeEvent.sendCodeRequested(phoneNumber: '+7999'));
      await _pump();

      expect(sink.names, ['login_code_request_failed']);
      expect(sink.events.single.parameters, {'reason': 'rate_limited'});
    });
  });
}
