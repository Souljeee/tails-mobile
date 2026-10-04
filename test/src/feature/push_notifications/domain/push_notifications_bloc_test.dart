import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/utils/logger/logger.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/devices_remote_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/dtos/push_message_dto.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/push_messaging_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/push_notifications_repository.dart';
import 'package:tails_mobile/src/feature/push_notifications/domain/push_notifications_bloc.dart';

import '../../../../helpers/fake_rest_client.dart';
import '../../../../helpers/push_fakes.dart';

/// Ждёт, пока состояние блока начнёт удовлетворять [test].
Future<S> _until<S>(Stream<S> stream, bool Function(S state) test) =>
    stream.firstWhere(test).timeout(const Duration(seconds: 2));

void main() {
  late FakePushMessagingDataSource messaging;
  late FakeLocalNotificationsDataSource local;
  late FakeRestClient client;
  late PushNotificationsRepository repository;
  late StreamController<AuthorizationStatus> authStatus;
  late PushNotificationsBloc bloc;

  setUp(() {
    messaging = FakePushMessagingDataSource();
    local = FakeLocalNotificationsDataSource();
    client = FakeRestClient();
    authStatus = StreamController<AuthorizationStatus>.broadcast();
    repository = PushNotificationsRepository(
      messagingDataSource: messaging,
      localNotificationsDataSource: local,
      devicesRemoteDataSource: DevicesRemoteDataSource(restClient: client),
      logger: const NoOpLogger(),
    );
  });

  PushNotificationsBloc createBloc(AuthorizationStatus initial) => bloc = PushNotificationsBloc(
    repository: repository,
    initialAuthorizationStatus: initial,
    authorizationStatus: authStatus.stream,
  );

  tearDown(() async {
    await bloc.close();
    await authStatus.close();
    await messaging.dispose();
    await local.dispose();
  });

  test('авторизованный пользователь при запуске подключается к push', () async {
    createBloc(AuthorizationStatus.authorized);

    final state = await _until(bloc.stream, (s) => s.status == PushNotificationsStatus.connected);

    expect(state.status, PushNotificationsStatus.connected);
    expect(client.last.path, '/devices/register/');
  });

  test('неавторизованный пользователь не подключается', () async {
    createBloc(AuthorizationStatus.notAuthorized);

    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.status, PushNotificationsStatus.idle);
    expect(client.requests, isEmpty);
    expect(messaging.requestPermissionCalls, 0);
  });

  test('после входа подключается, после выхода отключается', () async {
    createBloc(AuthorizationStatus.notAuthorized);

    authStatus.add(AuthorizationStatus.authorized);
    await _until(bloc.stream, (s) => s.status == PushNotificationsStatus.connected);

    authStatus.add(AuthorizationStatus.notAuthorized);
    await _until(bloc.stream, (s) => s.status == PushNotificationsStatus.idle);

    expect(messaging.deleteTokenCalls, 1);
  });

  test('запрет уведомлений отражается в состоянии', () async {
    messaging.permission = PushPermissionStatus.denied;
    createBloc(AuthorizationStatus.authorized);

    final state = await _until(
      bloc.stream,
      (s) => s.status == PushNotificationsStatus.permissionDenied,
    );

    expect(state.status, PushNotificationsStatus.permissionDenied);
  });

  test('ненастроенный Firebase даёт состояние unavailable', () async {
    messaging.isConfigured = false;
    createBloc(AuthorizationStatus.authorized);

    final state = await _until(bloc.stream, (s) => s.status == PushNotificationsStatus.unavailable);

    expect(state.status, PushNotificationsStatus.unavailable);
  });

  test('ошибка регистрации даёт состояние failure', () async {
    client.handler = (_) => throw const ClientException(message: 'нет сети');
    createBloc(AuthorizationStatus.authorized);

    final state = await runZonedGuarded(
      () => _until(bloc.stream, (s) => s.status == PushNotificationsStatus.failure),
      (_, _) {},
    );

    expect(state?.status, PushNotificationsStatus.failure);
  });

  test('нажатие на уведомление попадает в состояние', () async {
    createBloc(AuthorizationStatus.authorized);
    await _until(bloc.stream, (s) => s.status == PushNotificationsStatus.connected);

    messaging.opened.add(
      const PushMessageDto(title: 'Бакс: Корм', data: {'event_id': '7', 'type': 'standard'}),
    );
    final first = await _until(bloc.stream, (s) => s.openedCount == 1);

    expect(first.lastOpened?.title, 'Бакс: Корм');
    expect(first.lastOpened?.payload.eventId, 7);

    // Повторное нажатие на то же уведомление тоже замечается.
    messaging.opened.add(
      const PushMessageDto(title: 'Бакс: Корм', data: {'event_id': '7', 'type': 'standard'}),
    );
    final second = await _until(bloc.stream, (s) => s.openedCount == 2);

    expect(second.openedCount, 2);
  });
}
