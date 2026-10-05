import 'package:flutter_test/flutter_test.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:tails_mobile/src/feature/auth/data/repositories/auth_repository.dart';

import '../../../../../helpers/fake_rest_client.dart';

const _token = OAuth2Token(
  accessToken: 'access',
  refreshToken: 'refresh-token',
  accessExpires: 1,
  refreshExpires: 2,
);

void main() {
  late FakeRestClient notAuthClient;
  late FakeRestClient authorizedClient;
  late FakeTokenStorage tokenStorage;
  late AuthRepository repository;

  setUp(() {
    notAuthClient = FakeRestClient();
    authorizedClient = FakeRestClient();
    tokenStorage = FakeTokenStorage(_token);
    repository = AuthRepository(
      authRemoteDataSource: AuthRemoteDataSource(
        restClient: notAuthClient,
        authorizedRestClient: authorizedClient,
      ),
      tokenStorage: tokenStorage,
    );
  });

  group('logout', () {
    test('отправляет refresh-токен через авторизованный клиент и очищает токены', () async {
      await repository.logout();

      expect(notAuthClient.requests, isEmpty);
      expect(authorizedClient.last.method, 'POST');
      expect(authorizedClient.last.path, '/auth/logout/');
      expect(authorizedClient.last.body, {'refresh': 'refresh-token'});
      expect(tokenStorage.token, isNull);
    });

    test('очищает токены, даже если сервер недоступен, и пробрасывает ошибку', () async {
      authorizedClient.handler = (_) => throw const ClientException(message: 'нет сети');

      await expectLater(repository.logout(), throwsA(isA<ClientException>()));

      expect(tokenStorage.token, isNull);
      expect(tokenStorage.clearCalls, 1);
    });

    test('перед выходом вызывает beforeLogout, пока токены ещё действуют', () async {
      OAuth2Token? tokenInHook;
      final calls = <String>[];
      authorizedClient.handler = (request) {
        calls.add(request.path);

        return null;
      };
      repository = AuthRepository(
        authRemoteDataSource: AuthRemoteDataSource(
          restClient: notAuthClient,
          authorizedRestClient: authorizedClient,
        ),
        tokenStorage: tokenStorage,
        beforeLogout: () async {
          calls.add('beforeLogout');
          tokenInHook = tokenStorage.token;
        },
      );

      await repository.logout();

      expect(calls, ['beforeLogout', '/auth/logout/']);
      expect(tokenInHook, _token);
      expect(tokenStorage.token, isNull);
    });

    test('ошибка beforeLogout не мешает выйти и пробрасывается после выхода', () async {
      repository = AuthRepository(
        authRemoteDataSource: AuthRemoteDataSource(
          restClient: notAuthClient,
          authorizedRestClient: authorizedClient,
        ),
        tokenStorage: tokenStorage,
        beforeLogout: () async => throw StateError('не отвязали устройство'),
      );

      await expectLater(repository.logout(), throwsStateError);

      expect(authorizedClient.last.path, '/auth/logout/');
      expect(tokenStorage.token, isNull);
    });

    test('при ошибках и подготовки, и выхода пробрасывается ошибка выхода', () async {
      authorizedClient.handler = (_) => throw const ClientException(message: 'нет сети');
      repository = AuthRepository(
        authRemoteDataSource: AuthRemoteDataSource(
          restClient: notAuthClient,
          authorizedRestClient: authorizedClient,
        ),
        tokenStorage: tokenStorage,
        beforeLogout: () async => throw StateError('не отвязали устройство'),
      );

      await expectLater(repository.logout(), throwsA(isA<ClientException>()));

      expect(tokenStorage.token, isNull);
    });

    test('без сохранённого токена не ходит на сервер, но очищает хранилище', () async {
      tokenStorage.token = null;

      await repository.logout();

      expect(authorizedClient.requests, isEmpty);
      expect(tokenStorage.clearCalls, 1);
    });
  });

  group('afterSessionCleared', () {
    AuthRepository build(Future<void> Function() hook) => AuthRepository(
      authRemoteDataSource: AuthRemoteDataSource(
        restClient: notAuthClient,
        authorizedRestClient: authorizedClient,
      ),
      tokenStorage: tokenStorage,
      afterSessionCleared: hook,
    );

    test('вызывается после очистки токенов при выходе', () async {
      var tokenWasCleared = false;
      repository = build(() async => tokenWasCleared = tokenStorage.token == null);

      await repository.logout();

      expect(tokenWasCleared, isTrue);
    });

    test('вызывается, даже если сервер недоступен', () async {
      authorizedClient.handler = (_) => throw const ClientException(message: 'нет сети');
      var calls = 0;
      repository = build(() async => calls++);

      await expectLater(repository.logout(), throwsA(isA<ClientException>()));

      expect(calls, 1);
    });

    test('вызывается при clearSession', () async {
      var calls = 0;
      repository = build(() async => calls++);

      await repository.clearSession();

      expect(calls, 1);
      expect(tokenStorage.token, isNull);
    });

    test('ошибка хука не мешает выйти', () async {
      repository = build(() async => throw StateError('нет доступа к файлам'));

      await repository.logout();

      expect(tokenStorage.token, isNull);
    });
  });
}
