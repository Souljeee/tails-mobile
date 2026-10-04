import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/data_sources/notifications_inbox_remote_data_source.dart';

import '../../../../helpers/fake_rest_client.dart';

Map<String, Object?> _item(String id, {bool isRead = false}) => {
  'id': id,
  'kind': 'event',
  'title': 'Таблетка',
  'body': 'Пора',
  'created_at': '2026-10-04T09:00:00Z',
  'is_read': isRead,
  'pet_id': 4,
  'event_id': 'e-1',
  'event_type': 'dailyPills',
  'notification_type': 'standard',
  'occurrence_date': '2026-10-04',
  'occurrence_time': '06:00',
};

void main() {
  late FakeRestClient client;
  late NotificationsInboxRemoteDataSource dataSource;

  setUp(() {
    client = FakeRestClient();
    dataSource = NotificationsInboxRemoteDataSource(restClient: client);
  });

  group('getNotifications', () {
    test('первая страница запрашивается без курсора и фильтра', () async {
      client.handler = (_) => {'results': <Object?>[], 'next_cursor': null, 'unread_count': 0};

      await dataSource.getNotifications();

      expect(client.last.method, 'GET');
      expect(client.last.path, '/notifications/');
      expect(client.last.queryParams, {'limit': '30'});
    });

    test('передаёт курсор и фильтр непрочитанных', () async {
      client.handler = (_) => {'results': <Object?>[], 'next_cursor': null, 'unread_count': 0};

      await dataSource.getNotifications(cursor: 'abc', unreadOnly: true, limit: 10);

      expect(client.last.queryParams, {'limit': '10', 'cursor': 'abc', 'unread': 'true'});
    });

    test('разбирает страницу', () async {
      client.handler = (_) => {
        'results': [_item('n-1'), _item('n-2', isRead: true)],
        'next_cursor': 'next',
        'unread_count': 7,
      };

      final page = await dataSource.getNotifications();

      expect(page.nextCursor, 'next');
      expect(page.unreadCount, 7);
      expect(page.results.map((item) => item.id), ['n-1', 'n-2']);
      expect(page.results.first.isRead, isFalse);
      expect(page.results.last.isRead, isTrue);
      expect(page.results.first.petId, 4);
      expect(page.results.first.eventId, 'e-1');
      expect(page.results.first.eventType, 'dailyPills');
      expect(page.results.first.occurrenceDate, '2026-10-04');
    });

    test('объявление без питомца и события', () async {
      client.handler = (_) => {
        'results': [
          {
            'id': 'a-1',
            'kind': 'announcement',
            'title': 'Новое',
            'body': '',
            'created_at': '2026-10-04T09:00:00Z',
            'is_read': false,
            'pet_id': null,
            'event_id': null,
            'event_type': '',
          },
        ],
        'next_cursor': null,
        'unread_count': 1,
      };

      final item = (await dataSource.getNotifications()).results.single;

      expect(item.kind, 'announcement');
      expect(item.petId, isNull);
      expect(item.eventId, isNull);
    });

    test('неожиданный ответ — FormatException', () {
      client.handler = (_) => 'не json-объект';

      expect(dataSource.getNotifications(), throwsFormatException);
    });

    test('элемент без id — FormatException', () {
      client.handler = (_) => {
        'results': [
          {'created_at': '2026-10-04T09:00:00Z'},
        ],
        'next_cursor': null,
        'unread_count': 0,
      };

      expect(dataSource.getNotifications(), throwsFormatException);
    });
  });

  group('счётчик и отметки', () {
    test('getUnreadCount', () async {
      client.handler = (_) => {'unread_count': 3};

      expect(await dataSource.getUnreadCount(), 3);
      expect(client.last.method, 'GET');
      expect(client.last.path, '/notifications/unread-count/');
    });

    test('markRead отправляет POST и возвращает число непрочитанных', () async {
      client.handler = (_) => {'unread_count': 2};

      expect(await dataSource.markRead('n-1'), 2);
      expect(client.last.method, 'POST');
      expect(client.last.path, '/notifications/n-1/read/');
    });

    test('markAllRead отправляет POST', () async {
      client.handler = (_) => {'unread_count': 0};

      expect(await dataSource.markAllRead(), 0);
      expect(client.last.method, 'POST');
      expect(client.last.path, '/notifications/read-all/');
    });

    test('ответ без unread_count — FormatException', () {
      client.handler = (_) => <String, Object?>{};

      expect(dataSource.markRead('n-1'), throwsFormatException);
    });
  });
}
