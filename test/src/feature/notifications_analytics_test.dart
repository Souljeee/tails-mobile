import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/models/inbox_item.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/notifications_inbox_bloc.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';
import 'package:tails_mobile/src/feature/profile/notifications_settings/domain/notifications_settings_bloc.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/devices_remote_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/dtos/push_message_dto.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/push_notifications_repository.dart';
import 'package:tails_mobile/src/feature/push_notifications/domain/push_notifications_bloc.dart';

import '../../helpers/fake_rest_client.dart';
import '../../helpers/inbox_fakes.dart';
import '../../helpers/profile_fakes.dart';
import '../../helpers/push_fakes.dart';
import '../../helpers/recording_analytics_sink.dart';

void main() {
  late RecordingAnalyticsSink sink;

  setUp(() {
    sink = RecordingAnalyticsSink();
    TailsAnalytics.configure(sinks: [sink]);
  });

  tearDown(TailsAnalytics.reset);

  group('push', () {
    late FakePushMessagingDataSource messaging;
    late FakeLocalNotificationsDataSource local;
    late PushNotificationsRepository repository;
    late StreamController<AuthorizationStatus> authStatus;
    late PushNotificationsBloc bloc;

    setUp(() {
      messaging = FakePushMessagingDataSource();
      local = FakeLocalNotificationsDataSource();
      authStatus = StreamController<AuthorizationStatus>.broadcast();
      repository = PushNotificationsRepository(
        messagingDataSource: messaging,
        localNotificationsDataSource: local,
        devicesRemoteDataSource: DevicesRemoteDataSource(restClient: FakeRestClient()),
      );
      bloc = PushNotificationsBloc(
        repository: repository,
        initialAuthorizationStatus: AuthorizationStatus.authorized,
        authorizationStatus: authStatus.stream,
      );
    });

    tearDown(() async {
      await bloc.close();
      await authStatus.close();
      await messaging.dispose();
      await local.dispose();
    });

    test('разрешение выдано: push_permission_result и свойство push_status', () async {
      await bloc.stream.firstWhere((s) => s.status == PushNotificationsStatus.connected);

      expect(sink.names, ['push_permission_result']);
      expect(sink.events.single.parameters, {'status': 'granted'});
      expect(sink.properties[TailsAnalyticsUserProperty.pushStatus], 'granted');
    });

    test('повторное подключение с тем же результатом не дублирует событие', () async {
      await bloc.stream.firstWhere((s) => s.status == PushNotificationsStatus.connected);

      authStatus.add(AuthorizationStatus.authorized);
      await pumpEventQueue();

      expect(sink.names, ['push_permission_result']);
    });

    test('открытие и получение в открытом приложении', () async {
      await bloc.stream.firstWhere((s) => s.status == PushNotificationsStatus.connected);
      sink.events.clear();

      messaging.messages.add(
        const PushMessageDto(title: 'a', body: 'b', data: {'type': 'reminder'}),
      );
      messaging.opened.add(const PushMessageDto(title: 'a', body: 'b', data: {'type': 'final'}));
      await pumpEventQueue();

      expect(sink.names, ['push_received_foreground', 'push_opened']);
      expect(sink.events[0].parameters, {'type': 'reminder'});
      expect(sink.events[1].parameters, {'type': 'final'});
    });
  });

  group('настройки уведомлений', () {
    late FakeProfileRepository repository;
    late NotificationsSettingsBloc bloc;

    setUp(() {
      repository = FakeProfileRepository();
      bloc = NotificationsSettingsBloc(profileRepository: repository);
    });

    tearDown(() => bloc.close());

    test('переключатель отправляет событие после подтверждения сервером', () async {
      bloc.add(const NotificationsSettingsEvent.started());
      await pumpEventQueue();

      bloc.add(
        const NotificationsSettingsEvent.toggled(
          category: NotificationCategory.vetVisits,
          enabled: false,
        ),
      );
      await pumpEventQueue();

      expect(sink.names, ['notification_setting_changed']);
      expect(sink.events.single.parameters, {'setting': 'vet_visits', 'enabled': false});
    });

    test('ошибка сохранения не отправляет событие', () async {
      bloc.add(const NotificationsSettingsEvent.started());
      await pumpEventQueue();
      repository.setNotificationError = Exception('x');

      bloc.add(
        const NotificationsSettingsEvent.toggled(
          category: NotificationCategory.walks,
          enabled: false,
        ),
      );
      await pumpEventQueue();

      expect(sink.events, isEmpty);
    });

    test('открытие системных настроек', () async {
      bloc.add(const NotificationsSettingsEvent.openSettingsRequested());
      await pumpEventQueue();

      expect(sink.names, ['notifications_open_system_settings']);
    });
  });

  group('центр уведомлений', () {
    late FakeNotificationsInboxRepository inbox;
    late NotificationsInboxBloc bloc;

    setUp(() {
      inbox = FakeNotificationsInboxRepository(
        items: [
          fakeInboxItem('n1', petId: 1),
          fakeInboxItem('n2', isRead: true, kind: InboxItemKind.announcement),
        ],
      );
      bloc = NotificationsInboxBloc(
        inboxRepository: inbox,
        petRepository: FakePetRepository(),
        profileRepository: FakeProfileRepository(),
      );
    });

    tearDown(() async {
      await bloc.close();
      await inbox.dispose();
    });

    test('открытие, фильтр, элемент, прочитать все', () async {
      bloc.add(const NotificationsInboxEvent.started());
      await pumpEventQueue();
      bloc
        ..add(const NotificationsInboxEvent.filterChanged(filter: NotificationsInboxFilter.unread))
        ..add(const NotificationsInboxEvent.filterChanged(filter: NotificationsInboxFilter.unread));
      await pumpEventQueue();
      bloc.add(const NotificationsInboxEvent.itemOpened(id: 'n1'));
      await pumpEventQueue();
      bloc.add(const NotificationsInboxEvent.readAllRequested());
      await pumpEventQueue();

      expect(sink.names.first, 'inbox_opened');
      expect(sink.names.where((n) => n == 'inbox_filter_changed').length, 1);
      expect(sink.events.firstWhere((e) => e.name == 'inbox_filter_changed').parameters, {
        'filter': 'unread',
      });
      expect(sink.names, contains('inbox_item_opened'));
    });
  });
}
