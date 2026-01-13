import 'package:tails_mobile/src/feature/auth/data/data_sorces/auth_remote_data_source.dart';

/// {@template auth_repository}
/// A repository that fetches auth data from the remote source.
/// {@endtemplate}
class AuthRepository {
  /// {@macro auth_repository}
  final AuthRemoteDataSource authRemoteDataSource;

  /// {@macro auth_repository}
  const AuthRepository({
    required this.authRemoteDataSource,
  });

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
      authRemoteDataSource.sendCode(phoneNumber: phoneNumber);
}
