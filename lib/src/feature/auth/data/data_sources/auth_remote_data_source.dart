import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/dtos/tokens_dto.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/dtos/verify_code_result.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/account_blocked_exception.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/code_sending_timer_exceptions.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/invalid_code_exception.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/invalid_number_format.dart';

/// {@template auth_remote_data_source}
/// A data source that fetches auth data from the remote source.
/// {@endtemplate}
class AuthRemoteDataSource {
  /// Клиент без авторизации: отправка и проверка кода.
  final RestClient restClient;

  /// Клиент с токеном пользователя: выход из аккаунта требует авторизации.
  final RestClient authorizedRestClient;

  /// {@macro auth_remote_data_source}
  const AuthRemoteDataSource({required this.restClient, required this.authorizedRestClient});

  /// Бекенд может отдавать expires как секунды или миллисекунды с эпохи.
  /// Нормализуем к миллисекундам при создании токена.
  int _toEpochMillis(int value) => value < 1000000000000 ? value * 1000 : value;

  /// Method to send a code to the user's phone number.
  ///
  /// Throws InvalidPhoneNumberFormatException if the phone number format is invalid.
  /// Throws CodeSendingTimerException if the code sending timer is not started.
  /// Throws RestClientException if the request fails.
  ///
  /// phoneNumber - The user's phone number to send the code to.
  ///
  /// Returns void if the code is sent successfully.
  Future<void> sendCode({required String phoneNumber}) async {
    try {
      await restClient.post('/auth/send-code/', body: {'phone_number': phoneNumber});
    } on RestClientException catch (e) {
      if (e.statusCode == 400) {
        throw InvalidPhoneNumberFormatException(phoneNumber: phoneNumber);
      }

      if (e.statusCode == 429) {
        throw const CodeSendingTimerException();
      }

      rethrow;
    }
  }

  /// Method to verify a code for the user's phone number.
  ///
  /// Throws InvalidCodeException if the code is invalid.
  /// Throws AccountBlockedException if the account is blocked.
  /// Throws RestClientException if the request fails.
  ///
  /// phoneNumber - The user's phone number to verify the code for.
  /// code - The code to verify.
  ///
  /// Returns [VerifyCodeResult] (токены и сведения о пользователе), если код подтверждён.
  Future<VerifyCodeResult> verifyCode({required String phoneNumber, required String code}) async {
    try {
      final response = await restClient.post(
        '/auth/verify-code/',
        body: {'phone_number': phoneNumber, 'code': code},
      );

      if (response == null) {
        throw const ClientException(message: 'Response is null');
      }

      if (response is! Map) {
        throw ClientException(
          message: 'Unexpected response type for verify-code',
          cause: response.runtimeType,
        );
      }

      final token = TokensDto.fromJson(Map<String, dynamic>.from(response));

      return VerifyCodeResult(
        token: OAuth2Token(
          accessToken: token.access,
          refreshToken: token.refresh,
          accessExpires: _toEpochMillis(token.accessExpires),
          refreshExpires: _toEpochMillis(token.refreshExpires),
        ),
        isNewUser: token.isNewUser,
        userId: token.userId,
      );
    } on RestClientException catch (e) {
      if (e.statusCode == 400) {
        throw InvalidCodeException(code: code, phoneNumber: phoneNumber);
      }

      if (e.statusCode == 403) {
        throw AccountBlockedException(phoneNumber: phoneNumber);
      }

      rethrow;
    }
  }

  /// Отзывает refresh-токен на сервере.
  ///
  /// Бэкенд принимает только токен текущей сессии и только от авторизованного пользователя.
  ///
  /// Throws RestClientException if the request fails.
  Future<void> logout({required String refreshToken}) async {
    await authorizedRestClient.post('/auth/logout/', body: {'refresh': refreshToken});
  }
}
