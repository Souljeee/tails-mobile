import 'package:flutter_test/flutter_test.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/refresh_service_impl.dart';

class _FakeRestClient implements RestClient {
  _FakeRestClient(this._handler);

  final Future<Object?> Function(String path, Map<String, Object?> body) _handler;

  @override
  Future<Object?> post(
    String path, {
    required Map<String, Object?> body,
    Map<String, String>? headers,
    Map<String, String?>? queryParams,
  }) => _handler(path, body);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _oldToken = OAuth2Token(
  accessToken: 'old-access',
  refreshToken: 'old-refresh',
  accessExpires: 1,
  refreshExpires: 2,
);

void main() {
  test(
    'refresh разбирает ответ в формате access/refresh и нормализует expires в миллисекунды',
    () async {
      String? requestedPath;
      Map<String, Object?>? requestedBody;

      final service = RefreshServiceImpl(
        restClient: _FakeRestClient((path, body) async {
          requestedPath = path;
          requestedBody = body;

          return {
            'refresh': 'new-refresh',
            'access': 'new-access',
            'access_expires': 1790716017,
            'refresh_expires': 1791305450,
          };
        }),
      );

      final token = await service.refresh(_oldToken);

      expect(requestedPath, '/auth/token/refresh/');
      expect(requestedBody, {'refresh': 'old-refresh'});
      expect(token.accessToken, 'new-access');
      expect(token.refreshToken, 'new-refresh');
      expect(token.accessExpires, 1790716017000);
      expect(token.refreshExpires, 1791305450000);
    },
  );

  test('refresh не трогает expires, которые уже в миллисекундах', () async {
    final service = RefreshServiceImpl(
      restClient: _FakeRestClient(
        (_, _) async => {
          'refresh': 'r',
          'access': 'a',
          'access_expires': 1790716017000,
          'refresh_expires': 1791305450000,
        },
      ),
    );

    final token = await service.refresh(_oldToken);

    expect(token.accessExpires, 1790716017000);
  });

  test('refresh бросает RevokeTokenException при неожиданном формате ответа', () async {
    final service = RefreshServiceImpl(
      restClient: _FakeRestClient((_, _) async => {'access_token': 'a'}),
    );

    await expectLater(service.refresh(_oldToken), throwsA(isA<RevokeTokenException>()));
  });

  test('refresh бросает RevokeTokenException при пустом или нестроковом ответе', () async {
    await expectLater(
      RefreshServiceImpl(restClient: _FakeRestClient((_, _) async => null)).refresh(_oldToken),
      throwsA(isA<RevokeTokenException>()),
    );
    await expectLater(
      RefreshServiceImpl(restClient: _FakeRestClient((_, _) async => 'oops')).refresh(_oldToken),
      throwsA(isA<RevokeTokenException>()),
    );
  });

  test('сообщение об ошибке не содержит токены', () async {
    final service = RefreshServiceImpl(
      restClient: _FakeRestClient((_, _) async => {'access': 'secret-access'}),
    );

    try {
      await service.refresh(_oldToken);
      fail('Ожидалось исключение');
    } on RevokeTokenException catch (e) {
      expect(e.message, isNot(contains('secret-access')));
      expect(e.message, isNot(contains('old-refresh')));
    }
  });

  test(
    '401 от сервера превращается в RevokeTokenException, другие ошибки пробрасываются',
    () async {
      final revoked = RefreshServiceImpl(
        restClient: _FakeRestClient(
          (_, _) async => throw const ClientException(message: 'unauthorized', statusCode: 401),
        ),
      );
      await expectLater(revoked.refresh(_oldToken), throwsA(isA<RevokeTokenException>()));

      final offline = RefreshServiceImpl(
        restClient: _FakeRestClient(
          (_, _) async => throw const ConnectionException(message: 'offline'),
        ),
      );
      await expectLater(offline.refresh(_oldToken), throwsA(isA<ConnectionException>()));
    },
  );
}
