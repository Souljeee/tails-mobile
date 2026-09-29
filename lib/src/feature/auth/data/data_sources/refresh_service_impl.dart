import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/dtos/tokens_dto.dart';

class RefreshServiceImpl implements RefreshService<OAuth2Token> {
  final RestClient restClient;

  RefreshServiceImpl({required this.restClient});

  /// Бекенд может отдавать expires как секунды или миллисекунды с эпохи.
  /// Нормализуем к миллисекундам.
  int _toEpochMillis(int value) {
    // 1e12 ~ 2001-09-09 в миллисекундах; современные millis всегда > 1e12.
    // В секундах сейчас ~ 1.7e9.
    return value < 1000000000000 ? value * 1000 : value;
  }

  @override
  Future<bool> isAccessTokenValid(OAuth2Token token) {
    return Future.value(
      _toEpochMillis(token.accessExpires) > DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<bool> isRefreshTokenValid(OAuth2Token token) {
    return Future.value(
      _toEpochMillis(token.refreshExpires) > DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<OAuth2Token> refresh(OAuth2Token token) async {
    final Object? response;

    try {
      response = await restClient.post(
        '/auth/token/refresh/',
        body: {'refresh': token.refreshToken},
      );
    } on RestClientException catch (e) {
      if (e.statusCode == 401) {
        throw const RevokeTokenException('Refresh token is rejected by the server');
      }

      rethrow;
    }

    if (response == null) {
      throw const RevokeTokenException('Response is null');
    }

    if (response is! Map) {
      throw RevokeTokenException('Unexpected response type: ${response.runtimeType}');
    }

    // Ответ refresh имеет тот же формат, что и ответ verify-code:
    // `access`, `refresh`, `access_expires`, `refresh_expires`.
    final TokensDto tokens;

    try {
      tokens = TokensDto.fromJson(Map<String, dynamic>.from(response));
    } on Object {
      // Не логируем содержимое ответа: в нём токены.
      throw const RevokeTokenException('Unexpected refresh response format');
    }

    return OAuth2Token(
      accessToken: tokens.access,
      refreshToken: tokens.refresh,
      accessExpires: _toEpochMillis(tokens.accessExpires),
      refreshExpires: _toEpochMillis(tokens.refreshExpires),
    );
  }
}
