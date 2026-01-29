import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rest_client/rest_client.dart';

class SecureTokenStorage implements TokenStorage<OAuth2Token> {
  static const _accessTokenKey = 'authorization.access_token';
  static const _refreshTokenKey = 'authorization.refresh_token';
  static const _accessExpiresKey = 'authorization.access_expires';
  static const _refreshExpiresKey = 'authorization.refresh_expires';

  final FlutterSecureStorage _secureStorage;

  final _tokenStreamController = StreamController<OAuth2Token?>.broadcast();

  SecureTokenStorage({
    required FlutterSecureStorage secureStorage,
  }) : _secureStorage = secureStorage;

  @override
  Future<void> clear() async {
    await Future.wait(
      [
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _accessExpiresKey),
        _secureStorage.delete(key: _refreshExpiresKey),
      ],
      eagerError: true,
    );

    _tokenStreamController.add(null);
  }

  @override
  Future<void> close() async {
    await _tokenStreamController.close();
  }

  @override
  Stream<OAuth2Token?> getStream() => _tokenStreamController.stream;

  @override
  Future<OAuth2Token?> load() async {
    final List<String?> tokens = await Future.wait(
      [
        _secureStorage.read(key: _accessTokenKey),
        _secureStorage.read(key: _refreshTokenKey),
        _secureStorage.read(key: _accessExpiresKey),
        _secureStorage.read(key: _refreshExpiresKey),
      ],
      eagerError: true,
    );

    final accessToken = tokens[0];
    final refreshToken = tokens[1];
    final accessExpires = tokens[2];
    final refreshExpires = tokens[3];

    if (accessToken == null ||
        refreshToken == null ||
        accessExpires == null ||
        refreshExpires == null) {
      return null;
    }

    return OAuth2Token(
      accessToken: accessToken,
      refreshToken: refreshToken,
      accessExpires: int.parse(accessExpires),
      refreshExpires: int.parse(refreshExpires),
    );
  }

  @override
  Future<void> save(OAuth2Token tokenPair) async {
    await Future.wait(
      [
        _secureStorage.write(
          key: _accessTokenKey,
          value: tokenPair.accessToken,
        ),
        _secureStorage.write(
          key: _refreshTokenKey,
          value: tokenPair.refreshToken,
        ),
        _secureStorage.write(
          key: _accessExpiresKey,
          value: tokenPair.accessExpires.toString(),
        ),
        _secureStorage.write(
          key: _refreshExpiresKey,
          value: tokenPair.refreshExpires.toString(),
        ),
      ],
      eagerError: true,
    );

    _tokenStreamController.add(tokenPair);
  }
}
