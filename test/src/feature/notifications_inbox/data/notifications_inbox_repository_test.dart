import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/utils/logger/logger.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/data_sources/notifications_inbox_remote_data_source.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/models/inbox_item.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/notifications_inbox_repository.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

import '../../../../helpers/fake_rest_client.dart';

void main() {
  late FakeRestClient client;
  late StreamController<void> pushes;
  late StreamController<AuthorizationStatus> auth;
  late NotificationsInboxRepository repository;

  /// Состояние «сервера»: число непрочитанных.
  var unread = 2;

  setUp(() {
    unread = 2;
    client = FakeRestClient(
      handler: (request) {
        if (request.path == '/notifications/') {
          return {
            'results': [
              {
                'id': 'n-1',
                'kind': 'event',
                'title': 'Таблетка',
                'body': 'Пора',
                'created_at': '2026-10-04T09:00:00Z',
                'is_read': false,
                'pet_id': 4,
                'event_id': 'e-1',
                'event_type': 'dailyPills',
                'occurrence_date': '2026-10-04',
              },
              {
                'id': 'n-2',
                'kind': 'announcement',
                'title': 'Новое',
                'body': '',
                'created_at': '2026-10-03T09:00:00Z',
                'is_read': true,
                'event_type': 'неизвестный тип',
              },
            ],
            'next_cursor': 'next',
            'unread_count': unread,
          };
        }

        return {'unread_count': unread};
      },
    );
    pushes = StreamController<void>.broadcast();
    auth = StreamController<AuthorizationStatus>.broadcast();
    repository = NotificationsInboxRepository(
      remoteDataSource: NotificationsInboxRemoteDataSource(restClient: client),
      logger: const NoOpLogger(),
      incomingPushes: pushes.stream,
      authorizationStatus: auth.stream,
    );
  });

  tearDown(() async {
    await repository.dispose();
    await pushes.close();
    await auth.close();
  });

  Future<void> pump() => Future<void>.delayed(Duration.zero);

  group('getPage', () {
    test('превращает DTO в модели', () async {
      final page = await repository.getPage();

      expect(page.nextCursor, 'next');
      expect(page.unreadCount, 2);

      final first = page.items.first;

      expect(first.id, 'n-1');
      expect(first.kind, InboxItemKind.event);
      expect(first.isRead, isFalse);
      expect(first.petId, 4);
      expect(first.eventId, 'e-1');
      expect(first.eventType, ScheduleEventTypeEnum.dailyPills);
      expect(first.occurrenceDate, DateTime(2026, 10, 4));
      expect(first.createdAt, DateTime.utc(2026, 10, 4, 9).toLocal());

      final second = page.items.last;

      expect(second.kind, InboxItemKind.announcement);
      expect(second.isRead, isTrue);
      expect(second.eventType, isNull, reason: 'неизвестный тип события не должен ронять разбор');
    });

    test('запоминает число непрочитанных и сообщает о нём', () async {
      expect(repository.currentUnreadCount, isNull);

      final counts = <int>[];
      final subscription = repository.unreadCount.listen(counts.add);

      await repository.getPage();
      await repository.getPage();
      await pump();
      await subscription.cancel();

      expect(repository.currentUnreadCount, 2);
      expect(counts, [2], reason: 'одинаковое число повторно не отправляется');
    });

    test('передаёт курсор и фильтр', () async {
      await repository.getPage(cursor: 'c1', unreadOnly: true);

      expect(client.last.queryParams, {'limit': '30', 'cursor': 'c1', 'unread': 'true'});
    });
  });

  group('отметки прочитанным', () {
    test('markRead возвращает и публикует число с сервера', () async {
      final counts = <int>[];
      final subscription = repository.unreadCount.listen(counts.add);
      unread = 1;

      expect(await repository.markRead('n-1'), 1);
      await pump();
      await subscription.cancel();

      expect(client.last.path, '/notifications/n-1/read/');
      expect(counts, [1]);
    });

    test('markAllRead обнуляет счётчик', () async {
      unread = 0;

      await repository.markAllRead();

      expect(client.last.path, '/notifications/read-all/');
      expect(repository.currentUnreadCount, 0);
    });

    test('markReadSilently не пробрасывает ошибку', () async {
      client.handler = (_) => throw const ClientException(message: 'нет сети');

      await repository.markReadSilently('n-1');

      expect(client.requests, hasLength(1));
    });

    test('markRead пробрасывает ошибку', () {
      client.handler = (_) => throw const ClientException(message: 'нет сети');

      expect(repository.markRead('n-1'), throwsA(isA<ClientException>()));
    });
  });

  group('push в открытом приложении', () {
    test('сообщает об уведомлении и обновляет счётчик', () async {
      var incoming = 0;
      final incomingSubscription = repository.incoming.listen((_) => incoming++);
      final counts = <int>[];
      final countSubscription = repository.unreadCount.listen(counts.add);
      unread = 5;

      pushes.add(null);
      await pump();
      await pump();
      await incomingSubscription.cancel();
      await countSubscription.cancel();

      expect(incoming, 1);
      expect(client.last.path, '/notifications/unread-count/');
      expect(counts, [5]);
    });

    test('сбой обновления счётчика не ломает приложение', () async {
      client.handler = (_) => throw const ClientException(message: 'нет сети');

      pushes.add(null);
      await pump();
      await pump();

      expect(repository.currentUnreadCount, isNull);
    });
  });

  group('выход из аккаунта', () {
    test('сбрасывает счётчик, чтобы следующий пользователь не увидел чужие данные', () async {
      await repository.getPage();

      final counts = <int>[];
      final subscription = repository.unreadCount.listen(counts.add);

      auth.add(AuthorizationStatus.notAuthorized);
      await pump();
      await subscription.cancel();

      expect(repository.currentUnreadCount, isNull);
      expect(counts, [0]);
    });

    test('вход в аккаунт ничего не сбрасывает', () async {
      await repository.getPage();

      auth.add(AuthorizationStatus.authorized);
      await pump();

      expect(repository.currentUnreadCount, 2);
    });
  });
}
