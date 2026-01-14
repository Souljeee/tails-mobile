import 'package:rest_client/rest_client.dart';

class AuthClientImpl implements AuthorizationClient<OAuth2Token> {
  final RestClient restClient;

  AuthClientImpl({
    required this.restClient,
  });

  @override
  Future<bool> isAccessTokenValid(OAuth2Token token) {
    return Future.value(token.accessExpires > DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<bool> isRefreshTokenValid(OAuth2Token token) {
    return Future.value(token.refreshExpires > DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<OAuth2Token> refresh(OAuth2Token token) async {
    try {
      final response = await restClient.post(
        '/api/v1/auth/refresh',
        body: {
          'refresh_token': token.refreshToken,
        },
      );

      if (response == null) {
        throw const RevokeTokenException('Response is null');
      }

      return OAuth2Token(
        accessToken: response['access_token']! as String,
        refreshToken: response['refresh_token']! as String,
        accessExpires: (response['access_expires']! as num).toInt(),
        refreshExpires: (response['refresh_expires']! as num).toInt(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
