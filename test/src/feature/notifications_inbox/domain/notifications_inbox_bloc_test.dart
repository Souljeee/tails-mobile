import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/notifications_inbox_bloc.dart';

import '../../../../helpers/inbox_fakes.dart';
import '../../../../helpers/profile_fakes.dart';

class _ProfileRepository extends FakeProfileRepository {
  int settingsOpened = 0;

  @override
  Future<void> openSystemSettings() async => settingsOpened++;
}

void main() {
  late FakeNotificationsInboxRepository inbox;
  late FakePetRepository pets;
  late _ProfileRepository profile;
  late NotificationsInboxBloc bloc;

  setUp(() {
    inbox = FakeNotificationsInboxRepository(
      items: [
        fakeInboxItem('n1', petId: 1),
        fakeInboxItem('n2', petId: 1),
        fakeInboxItem('n3', isRead: true, petId: 2),
      ],
    );
    pets = FakePetRepository()..pets = [fakePet(1, 'Бакс'), fakePet(2, 'Мурка')];
    profile = _ProfileRepository();
    bloc = NotificationsInboxBloc(
      inboxRepository: inbox,
      petRepository: pets,
      profileRepository: profile,
    );
  });

  tearDown(() async {
    await bloc.close();
    await inbox.dispose();
  });

  /// Даёт блоку обработать события и ответы fake-репозиториев.
  Future<void> settle() => pumpEventQueue();

  Future<void> start() async {
    bloc.add(const NotificationsInboxEvent.started());
    await settle();
  }

  group('started', () {
    test('загружает список, питомцев и состояние системного разрешения', () async {
      profile.blocked = true;

      expect(bloc.state.status, NotificationsInboxStatus.loading);

      await start();

      expect(bloc.state.status, NotificationsInboxStatus.ready);
      expect(bloc.state.items.map((i) => i.id), ['n1', 'n2', 'n3']);
      expect(bloc.state.unreadCount, 2);
      expect(bloc.state.pets.keys, [1, 2]);
      expect(bloc.state.isBlockedBySystem, isTrue);
      expect(bloc.state.nextCursor, isNull);
    });

    test('ошибка загрузки даёт failure, повтор восстанавливает', () async {
      inbox.getPageError = Exception('offline');

      await start();

      expect(bloc.state.status, NotificationsInboxStatus.failure);

      inbox.getPageError = null;
      await start();

      expect(bloc.state.status, NotificationsInboxStatus.ready);
      expect(bloc.state.items, hasLength(3));
    });

    test('сбой загрузки питомцев не мешает списку', () async {
      pets.error = Exception('offline');

      await start();

      expect(bloc.state.status, NotificationsInboxStatus.ready);
      expect(bloc.state.items, hasLength(3));
      expect(bloc.state.pets, isEmpty);
    });
  });

  group('фильтр', () {
    test('«Непрочитанные» запрашивает только непрочитанные', () async {
      await start();

      bloc.add(
        const NotificationsInboxEvent.filterChanged(filter: NotificationsInboxFilter.unread),
      );
      await settle();

      expect(inbox.calls.last, 'getPage(cursor: null, unreadOnly: true)');
      expect(bloc.state.filter, NotificationsInboxFilter.unread);
      expect(bloc.state.items.map((i) => i.id), ['n1', 'n2']);
    });

    test('тот же фильтр не вызывает повторную загрузку', () async {
      await start();
      final callsBefore = inbox.calls.length;

      bloc.add(const NotificationsInboxEvent.filterChanged(filter: NotificationsInboxFilter.all));
      await settle();

      expect(inbox.calls.length, callsBefore);
    });

    test('пока грузится новый фильтр, старый список не показывается', () async {
      await start();

      inbox.getPageGate = Completer<void>();
      bloc.add(
        const NotificationsInboxEvent.filterChanged(filter: NotificationsInboxFilter.unread),
      );
      await settle();

      expect(bloc.state.status, NotificationsInboxStatus.loading);
      expect(bloc.state.items, isEmpty);

      inbox.getPageGate!.complete();
      await settle();

      expect(bloc.state.status, NotificationsInboxStatus.ready);
    });

    test('ответ устаревшей загрузки отбрасывается', () async {
      await start();

      // Первый запрос (непрочитанные) зависает, второй (все) завершается раньше.
      inbox.getPageGate = Completer<void>();
      bloc.add(
        const NotificationsInboxEvent.filterChanged(filter: NotificationsInboxFilter.unread),
      );
      await settle();

      final slowGate = inbox.getPageGate!;

      inbox.getPageGate = null;
      bloc.add(const NotificationsInboxEvent.filterChanged(filter: NotificationsInboxFilter.all));
      await settle();

      slowGate.complete();
      await settle();

      expect(bloc.state.filter, NotificationsInboxFilter.all);
      expect(bloc.state.items.map((i) => i.id), ['n1', 'n2', 'n3']);
    });
  });

  group('подгрузка страниц', () {
    setUp(() {
      inbox.pageSize = 2;
    });

    test('добавляет следующую страницу и перестаёт, когда страниц больше нет', () async {
      await start();

      expect(bloc.state.items.map((i) => i.id), ['n1', 'n2']);
      expect(bloc.state.hasMore, isTrue);

      bloc.add(const NotificationsInboxEvent.loadMoreRequested());
      await settle();

      expect(bloc.state.items.map((i) => i.id), ['n1', 'n2', 'n3']);
      expect(bloc.state.hasMore, isFalse);

      final callsBefore = inbox.calls.length;

      bloc.add(const NotificationsInboxEvent.loadMoreRequested());
      await settle();

      expect(inbox.calls.length, callsBefore);
    });

    test('повторные запросы во время загрузки страницы не дублируют её', () async {
      await start();
      inbox.getPageGate = Completer<void>();

      bloc
        ..add(const NotificationsInboxEvent.loadMoreRequested())
        ..add(const NotificationsInboxEvent.loadMoreRequested());
      await settle();

      expect(bloc.state.isLoadingMore, isTrue);
      expect(inbox.calls.where((c) => c.contains('cursor: 2')), hasLength(1));

      inbox.getPageGate!.complete();
      await settle();

      expect(bloc.state.isLoadingMore, isFalse);
      expect(bloc.state.items, hasLength(3));
    });

    test('ошибка не теряет загруженное, следующая попытка повторяет запрос', () async {
      await start();
      inbox.getPageError = Exception('offline');

      bloc.add(const NotificationsInboxEvent.loadMoreRequested());
      await settle();

      expect(bloc.state.items, hasLength(2));
      expect(bloc.state.isLoadingMore, isFalse);
      expect(bloc.state.hasMore, isTrue);

      inbox.getPageError = null;
      bloc.add(const NotificationsInboxEvent.loadMoreRequested());
      await settle();

      expect(bloc.state.items, hasLength(3));
    });

    test('уведомление, уже показанное на странице, не дублируется', () async {
      await start();

      // Пока пользователь листал, пришло новое: сервер сдвинул страницы на одну запись.
      inbox.items = [fakeInboxItem('n0'), ...inbox.items];
      inbox.pageSize = 2;

      bloc.add(const NotificationsInboxEvent.loadMoreRequested());
      await settle();

      final ids = bloc.state.items.map((i) => i.id).toList();

      expect(ids.toSet(), hasLength(ids.length));
    });
  });

  group('прочтение', () {
    test('нажатие делает строку прочитанной сразу и уменьшает счётчик', () async {
      await start();
      inbox.getPageGate = null;

      bloc.add(const NotificationsInboxEvent.itemOpened(id: 'n1'));
      await settle();

      expect(inbox.calls, contains('markRead(n1)'));
      expect(bloc.state.items.first.isRead, isTrue);
      expect(bloc.state.unreadCount, 1);
      expect(bloc.state.actionFailures, 0);
    });

    test('уже прочитанное уведомление запрос не отправляет', () async {
      await start();

      bloc.add(const NotificationsInboxEvent.itemOpened(id: 'n3'));
      await settle();

      expect(inbox.calls.where((c) => c.startsWith('markRead')), isEmpty);
      expect(bloc.state.unreadCount, 2);
    });

    test('неизвестный id игнорируется', () async {
      await start();

      bloc.add(const NotificationsInboxEvent.itemOpened(id: 'нет такого'));
      await settle();

      expect(inbox.calls.where((c) => c.startsWith('markRead')), isEmpty);
    });

    test('отказ сервера возвращает строку и счётчик и увеличивает actionFailures', () async {
      await start();
      inbox.markReadError = Exception('offline');

      bloc.add(const NotificationsInboxEvent.itemOpened(id: 'n1'));
      await settle();

      expect(bloc.state.items.first.isRead, isFalse);
      expect(bloc.state.unreadCount, 2);
      expect(bloc.state.actionFailures, 1);
    });

    test('«Прочитать все» во вкладке «Все» оставляет список, но всё прочитано', () async {
      await start();

      bloc.add(const NotificationsInboxEvent.readAllRequested());
      await settle();

      expect(inbox.calls, contains('markAllRead'));
      expect(bloc.state.items, hasLength(3));
      expect(bloc.state.items.every((i) => i.isRead), isTrue);
      expect(bloc.state.unreadCount, 0);
    });

    test('«Прочитать все» во вкладке «Непрочитанные» очищает список', () async {
      await start();
      bloc.add(
        const NotificationsInboxEvent.filterChanged(filter: NotificationsInboxFilter.unread),
      );
      await settle();

      bloc.add(const NotificationsInboxEvent.readAllRequested());
      await settle();

      expect(bloc.state.items, isEmpty);
      expect(bloc.state.isEmpty, isTrue);
      expect(bloc.state.unreadCount, 0);
    });

    test('«Прочитать все» без непрочитанных запрос не отправляет', () async {
      inbox.items = [fakeInboxItem('n3', isRead: true)];
      await start();

      bloc.add(const NotificationsInboxEvent.readAllRequested());
      await settle();

      expect(inbox.calls, isNot(contains('markAllRead')));
    });

    test('отказ сервера при «Прочитать все» возвращает прежнее состояние', () async {
      await start();
      inbox.markAllReadError = Exception('offline');

      bloc.add(const NotificationsInboxEvent.readAllRequested());
      await settle();

      expect(bloc.state.items.where((i) => !i.isRead), hasLength(2));
      expect(bloc.state.unreadCount, 2);
      expect(bloc.state.actionFailures, 1);
    });
  });

  group('обновление', () {
    test('pull-to-refresh подтягивает новые уведомления и завершает completer', () async {
      await start();
      inbox.items = [fakeInboxItem('n0'), ...inbox.items];

      final completer = Completer<void>();

      bloc.add(NotificationsInboxEvent.refreshRequested(completer: completer));
      await completer.future.timeout(const Duration(seconds: 2));

      expect(bloc.state.items.first.id, 'n0');
      expect(bloc.state.unreadCount, 3);
    });

    test('ошибка тихого обновления не заменяет показанный список', () async {
      await start();
      inbox.getPageError = Exception('offline');

      final completer = Completer<void>();

      bloc.add(NotificationsInboxEvent.refreshRequested(completer: completer));
      await completer.future.timeout(const Duration(seconds: 2));

      expect(bloc.state.status, NotificationsInboxStatus.ready);
      expect(bloc.state.items, hasLength(3));
    });

    test('push в открытом приложении обновляет список', () async {
      await start();
      inbox.items = [fakeInboxItem('n0'), ...inbox.items];

      inbox.incomingController.add(null);
      await settle();

      expect(bloc.state.items.first.id, 'n0');
    });

    test('число непрочитанных из репозитория попадает в состояние', () async {
      await start();

      inbox.unreadController.add(9);
      await settle();

      expect(bloc.state.unreadCount, 9);
    });

    test('возврат из настроек телефона обновляет баннер', () async {
      await start();

      expect(bloc.state.isBlockedBySystem, isFalse);

      profile.blocked = true;
      bloc.add(const NotificationsInboxEvent.systemStatusChecked());
      await settle();

      expect(bloc.state.isBlockedBySystem, isTrue);
    });

    test('открытие системных настроек', () async {
      bloc.add(const NotificationsInboxEvent.openSettingsRequested());
      await settle();

      expect(profile.settingsOpened, 1);
    });
  });
}
