import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/auth_remote_data_source.dart';

/// {@template auth_repository}
/// A repository that fetches auth data from the remote source.
/// {@endtemplate}
class AuthRepository {
  /// {@macro auth_repository}
  final AuthRemoteDataSource _authRemoteDataSource;
  final TokenStorage<OAuth2Token> _tokenStorage;

  /// {@macro auth_repository}
  const AuthRepository({
    required AuthRemoteDataSource authRemoteDataSource,
    required TokenStorage<OAuth2Token> tokenStorage,
  }) : _authRemoteDataSource = authRemoteDataSource,
       _tokenStorage = tokenStorage;

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

  /// Method to logout the user.
  ///
  /// Throws RestClientException if the request fails.
  ///
  /// Returns void if the logout is successful.
  Future<void> logout() => _authRemoteDataSource.logout();
}
