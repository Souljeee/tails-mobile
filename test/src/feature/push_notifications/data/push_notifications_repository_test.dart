import 'package:flutter_test/flutter_test.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/utils/logger/logger.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/devices_remote_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/dtos/push_message_dto.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/push_messaging_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/models/push_notification.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/models/push_payload.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/push_notifications_repository.dart';

import '../../../../helpers/fake_rest_client.dart';
import '../../../../helpers/push_fakes.dart';

const _eventMessage = PushMessageDto(
  messageId: 'm1',
  title: 'Бакс: Корм',
  body: 'Пора выполнить: Корм',
  data: {'event_id': '7', 'type': 'standard', 'date': '2026-10-05'},
);

void main() {
  late FakePushMessagingDataSource messaging;
  late FakeLocalNotificationsDataSource local;
  late FakeRestClient client;
  late PushNotificationsRepository repository;

  setUp(() {
    messaging = FakePushMessagingDataSource();
    local = FakeLocalNotificationsDataSource();
    client = FakeRestClient();
    repository = PushNotificationsRepository(
      messagingDataSource: messaging,
      localNotificationsDataSource: local,
      devicesRemoteDataSource: DevicesRemoteDataSource(restClient: client),
      logger: const NoOpLogger(),
    );
  });

  tearDown(() async {
    await messaging.dispose();
    await local.dispose();
  });

  /// Даёт обработаться событиям потоков.
  Future<void> pump() => Future<void>.delayed(Duration.zero);

  group('connectDevice', () {
    test('запрашивает разрешение и регистрирует токен с платформой', () async {
      final status = await repository.connectDevice();

      expect(status, PushConnectionStatus.connected);
      expect(messaging.requestPermissionCalls, 1);
      expect(client.requests, hasLength(1));
      expect(client.last.path, '/devices/register/');
      expect(client.last.body, {'fcm_token': 'token-1', 'platform': 'android'});
    });

    test('при запрете уведомлений всё равно регистрирует токен', () async {
      messaging.permission = PushPermissionStatus.denied;

      final status = await repository.connectDevice();

      expect(status, PushConnectionStatus.permissionDenied);
      expect(client.requests, hasLength(1));
    });

    test('если Firebase не настроен, ничего не делает', () async {
      messaging.isConfigured = false;

      final status = await repository.connectDevice();

      expect(status, PushConnectionStatus.unavailable);
      expect(messaging.requestPermissionCalls, 0);
      expect(local.initializeCalls, 0);
      expect(client.requests, isEmpty);
    });

    test('без токена не обращается к серверу', () async {
      messaging.token = null;

      final status = await repository.connectDevice();

      expect(status, PushConnectionStatus.unavailable);
      expect(client.requests, isEmpty);
    });

    test('повторный вызов инициализирует SDK и регистрирует токен один раз', () async {
      await repository.connectDevice();
      await repository.connectDevice();

      expect(messaging.initializeCalls, 1);
      expect(local.initializeCalls, 1);
      expect(messaging.getInitialMessageCalls, 1);
      expect(client.requests, hasLength(1));
    });

    test('пробрасывает ошибку сервера', () async {
      client.handler = (_) => throw const ClientException(message: 'нет сети');

      await expectLater(repository.connectDevice(), throwsA(isA<ClientException>()));
    });
  });

  group('обновление токена', () {
    test('регистрирует новый токен', () async {
      await repository.connectDevice();

      messaging.tokenRefresh.add('token-2');
      await pump();

      expect(client.requests, hasLength(2));
      expect(client.last.body, {'fcm_token': 'token-2', 'platform': 'android'});
    });

    test('не регистрирует уже зарегистрированный токен повторно', () async {
      await repository.connectDevice();

      messaging.tokenRefresh.add('token-1');
      await pump();

      expect(client.requests, hasLength(1));
    });

    test('ошибка регистрации не роняет поток', () async {
      await repository.connectDevice();
      client.handler = (_) => throw const ClientException(message: 'нет сети');

      messaging.tokenRefresh.add('token-2');
      await pump();

      // токен не зарегистрирован, поэтому следующая попытка отправит запрос снова
      client.handler = null;
      messaging.tokenRefresh.add('token-2');
      await pump();

      expect(client.requests, hasLength(3));
    });
  });

  group('уведомления в открытом приложении', () {
    test('на Android показываются локально с данными пуша', () async {
      await repository.connectDevice();

      messaging.messages.add(_eventMessage);
      await pump();

      expect(local.shown, hasLength(1));
      expect(local.shown.single.title, 'Бакс: Корм');
      expect(local.shown.single.body, 'Пора выполнить: Корм');
      expect(local.shown.single.payload, _eventMessage.data);
    });

    test('на iOS не дублируют системный баннер', () async {
      messaging.platform = 'ios';
      await repository.connectDevice();

      messaging.messages.add(_eventMessage);
      await pump();

      expect(local.shown, isEmpty);
    });

    test('после stop больше не показываются', () async {
      await repository.connectDevice();
      await repository.stop();

      messaging.messages.add(_eventMessage);
      await pump();

      expect(local.shown, isEmpty);
    });
  });

  group('открытые уведомления', () {
    late List<PushNotification> opened;

    setUp(() {
      opened = [];
      repository.openedNotifications.listen(opened.add);
    });

    test('нажатие из фона', () async {
      await repository.connectDevice();

      messaging.opened.add(_eventMessage);
      await pump();

      expect(opened, hasLength(1));
      expect(opened.single.title, 'Бакс: Корм');
      expect(opened.single.payload.eventId, 7);
      expect(opened.single.payload.date, DateTime(2026, 10, 5));
    });

    test('запуск закрытого приложения нажатием на уведомление', () async {
      messaging.initialMessage = _eventMessage;

      await repository.connectDevice();
      await pump();

      expect(opened, hasLength(1));
      expect(opened.single.payload.eventId, 7);
    });

    test('нажатие на локальное уведомление', () async {
      await repository.connectDevice();

      local.taps.add(_eventMessage.data);
      await pump();

      expect(opened, hasLength(1));
      expect(opened.single.payload.type, PushNotificationType.standard);
    });
  });

  group('unregisterDevice', () {
    test('отвязывает зарегистрированный токен', () async {
      await repository.connectDevice();

      await repository.unregisterDevice();

      expect(client.last.path, '/devices/unregister/');
      expect(client.last.body, {'fcm_token': 'token-1'});
    });

    test('без регистрации ничего не отправляет', () async {
      await repository.unregisterDevice();

      expect(client.requests, isEmpty);
    });

    test('не пробрасывает ошибку сервера', () async {
      await repository.connectDevice();
      client.handler = (_) => throw const ClientException(message: 'нет сети');

      await expectLater(repository.unregisterDevice(), completes);
    });
  });

  group('stop', () {
    test('удаляет токен устройства и забывает регистрацию', () async {
      await repository.connectDevice();

      await repository.stop();

      expect(messaging.deleteTokenCalls, 1);

      // После повторного входа тот же токен регистрируется заново.
      await repository.connectDevice();

      expect(client.requests, hasLength(2));
    });

    test('перестаёт реагировать на обновление токена', () async {
      await repository.connectDevice();
      await repository.stop();

      messaging.tokenRefresh.add('token-2');
      await pump();

      expect(client.requests, hasLength(1));
    });

    test('без инициализации SDK ничего не делает', () async {
      await repository.stop();

      expect(messaging.deleteTokenCalls, 0);
    });
  });
}
