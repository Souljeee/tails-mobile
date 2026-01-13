import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/code_sending_timer_exceptions.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/invalid_number_format.dart';

/// {@template auth_remote_data_source}
/// A data source that fetches auth data from the remote source.
/// {@endtemplate}
class AuthRemoteDataSource {
  /// {@macro auth_remote_data_source}
  final RestClient restClient;

  /// {@macro auth_remote_data_source}
  const AuthRemoteDataSource({
    required this.restClient,
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
  Future<void> sendCode({required String phoneNumber}) async {
    try {
      await restClient.post(
        '/auth/send-code/',
        body: {
          'phone_number': phoneNumber,
        },
      );
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
}
