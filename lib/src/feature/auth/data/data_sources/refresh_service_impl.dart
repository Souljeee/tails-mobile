import 'package:rest_client/rest_client.dart';
class RefreshServiceImpl implements RefreshService<OAuth2Token> {
  final RestClient restClient;

  RefreshServiceImpl({
    required this.restClient,
  });

  /// Бекенд может отдавать expires как секунды или миллисекунды с эпохи.
  /// Нормализуем к миллисекундам.
  int _toEpochMillis(int value) {
    // 1e12 ~ 2001-09-09 в миллисекундах; современные millis всегда > 1e12.
    // В секундах сейчас ~ 1.7e9.
    return value < 1000000000000 ? value * 1000 : value;
  }

  @override
  Future<bool> isAccessTokenValid(OAuth2Token token) {
    return Future.value(_toEpochMillis(token.accessExpires) > DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<bool> isRefreshTokenValid(OAuth2Token token) {
    return Future.value(_toEpochMillis(token.refreshExpires) > DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<OAuth2Token> refresh(OAuth2Token token) async {
    try {
      final response = await restClient.post(
        '/auth/token/refresh/',
        body: {
          'refresh': token.refreshToken,
        },
      );

      if (response == null) {
        throw const RevokeTokenException('Response is null');
      }

      if (response is! Map) {
        throw RevokeTokenException('Unexpected response type: ${response.runtimeType}');
      }

      final json = response.cast<String, Object?>();

      return OAuth2Token(
        accessToken: json['access_token']! as String,
        refreshToken: json['refresh_token']! as String,
        accessExpires: _toEpochMillis((json['access_expires']! as num).toInt()),
        refreshExpires: _toEpochMillis((json['refresh_expires']! as num).toInt()),
      );
    } catch (e) {
      if (e is RestClientException && e.statusCode == 401) {
        throw RevokeTokenException('Token with access token ${token.accessToken} and refresh token ${token.refreshToken} can not be refreshed');
      }
      
      rethrow;
    }
  }
}
