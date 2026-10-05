import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/auth_remote_data_source.dart';

/// {@template auth_repository}
/// A repository that fetches auth data from the remote source.
/// {@endtemplate}
class AuthRepository {
  /// {@macro auth_repository}
  final AuthRemoteDataSource _authRemoteDataSource;
  final TokenStorage<OAuth2Token> _tokenStorage;
  final Future<void> Function()? _beforeLogout;
  final Future<void> Function()? _afterSessionCleared;

  /// {@macro auth_repository}
  ///
  /// [beforeLogout] вызывается перед выходом, пока токены ещё действуют (например, чтобы
  /// отвязать устройство от push-уведомлений). Выход выполняется в любом случае, даже если
  /// он выбросил ошибку: она пробрасывается после выхода.
  ///
  /// [afterSessionCleared] вызывается после очистки токенов при выходе и при [clearSession]
  /// (например, чтобы удалить локальный журнал работы приложения). Её ошибка не мешает выходу.
  const AuthRepository({
    required AuthRemoteDataSource authRemoteDataSource,
    required TokenStorage<OAuth2Token> tokenStorage,
    Future<void> Function()? beforeLogout,
    Future<void> Function()? afterSessionCleared,
  }) : _authRemoteDataSource = authRemoteDataSource,
       _tokenStorage = tokenStorage,
       _beforeLogout = beforeLogout,
       _afterSessionCleared = afterSessionCleared;

    Stream<AuthorizationStatus> get authorizationStatus => _tokenStorage.getStream().map(
        (token) =>
            token != null ? AuthorizationStatus.authorized : AuthorizationStatus.notAuthorized,
      );

  /// Method to send a code to the user's phone number.
  ///
  /// Throws InvalidPhoneNumberFormatException if the phone number format is invalid.
  /// Throws CodeSendingTimerException if the code sending timer is not started.
  /// Throws RestClientException if the request fails.
  ///
  /// phoneNumber - The user's phone number to send the code to.
  ///
  /// Returns void if the code is sent successfully.
  Future<void> sendCode({required String phoneNumber}) =>
      _authRemoteDataSource.sendCode(phoneNumber: phoneNumber);

  /// Method to verify the code.
  ///
  /// Throws InvalidCodeException if the code is invalid.
  /// Throws AccountBlockedException if the account is blocked.
  /// Throws RestClientException if the request fails.
  ///
  /// code - The code to verify.
  /// phoneNumber - The user's phone number to verify the code for.
  Future<void> verifyCode({
    required String code,
    required String phoneNumber,
  }) async {
    final token = await _authRemoteDataSource.verifyCode(
      code: code,
      phoneNumber: phoneNumber,
    );

    await _tokenStorage.save(token);
  }

  /// Выход из аккаунта.
  ///
  /// Сначала просит сервер отозвать refresh-токен, но локальные токены очищаются в любом
  /// случае: пользователь, нажавший «Выйти», не должен остаться в приложении из-за сбоя сети.
  /// Ошибка отзыва на сервере пробрасывается после очистки. Ошибка [_beforeLogout] тоже:
  /// её запоминаем, выполняем выход до конца и пробрасываем в конце.
  ///
  /// Throws RestClientException if the server request fails.
  Future<void> logout() async {
    Object? beforeLogoutError;
    StackTrace? beforeLogoutStackTrace;

    try {
      await _beforeLogout?.call();
    } on Object catch (e, s) {
      beforeLogoutError = e;
      beforeLogoutStackTrace = s;
    }

    try {
      final token = await _tokenStorage.load();

      try {
        if (token != null) {
          await _authRemoteDataSource.logout(refreshToken: token.refreshToken);
        }
      } finally {
        await _tokenStorage.clear();
        await _clearLocalData();
      }
    } on Object {
      // Пробрасывается ошибка выхода; ошибку подготовки не теряем, а пишем в журнал.
      if (beforeLogoutError != null) {
        TailsLogger.warning(
          'Подготовка к выходу завершилась ошибкой',
          source: 'AuthRepository',
          error: beforeLogoutError,
          stackTrace: beforeLogoutStackTrace,
        );
      }
      rethrow;
    }

    if (beforeLogoutError != null) {
      Error.throwWithStackTrace(beforeLogoutError, beforeLogoutStackTrace!);
    }
  }

  /// Забывает локальную сессию без обращения к серверу.
  ///
  /// Нужно, когда сервер уже сам закрыл все сессии (например, после удаления аккаунта).
  Future<void> clearSession() async {
    await _tokenStorage.clear();
    await _clearLocalData();
  }

  Future<void> _clearLocalData() async {
    try {
      await _afterSessionCleared?.call();
    } on Object {
      // Сбой очистки локальных данных не должен мешать выходу из аккаунта.
    }
  }
}
