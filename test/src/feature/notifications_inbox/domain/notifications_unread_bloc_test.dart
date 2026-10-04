import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/notifications_unread_bloc.dart';

import '../../../../helpers/inbox_fakes.dart';

void main() {
  late FakeNotificationsInboxRepository inbox;
  late NotificationsUnreadBloc bloc;

  setUp(() {
    inbox = FakeNotificationsInboxRepository(
      items: [fakeInboxItem('n1'), fakeInboxItem('n2'), fakeInboxItem('n3', isRead: true)],
    );
    bloc = NotificationsUnreadBloc(inboxRepository: inbox);
  });

  tearDown(() async {
    await bloc.close();
    await inbox.dispose();
  });

  test('начинает с числа, которое репозиторий уже знает', () {
    expect(bloc.state.count, 2);
  });

  test('refreshRequested запрашивает число у сервера', () async {
    inbox.items = [fakeInboxItem('n1'), fakeInboxItem('n2'), fakeInboxItem('n4')];

    bloc.add(const NotificationsUnreadEvent.refreshRequested());
    await pumpEventQueue();

    expect(inbox.calls, contains('refreshUnreadCount'));
    expect(bloc.state.count, 3);
  });

  test('сбой запроса оставляет прежнее число', () async {
    inbox.unreadCountError = Exception('offline');

    bloc.add(const NotificationsUnreadEvent.refreshRequested());
    await pumpEventQueue();

    expect(bloc.state.count, 2);
  });

  test('следует за изменениями числа в репозитории', () async {
    inbox.unreadController.add(0);
    await pumpEventQueue();

    expect(bloc.state.count, 0);

    inbox.unreadController.add(5);
    await pumpEventQueue();

    expect(bloc.state.count, 5);
  });
}
