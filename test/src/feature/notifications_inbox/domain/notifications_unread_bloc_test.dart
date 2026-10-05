import 'package:bloc/bloc.dart';
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

  test('сбой запроса попадает в BlocObserver', () async {
    final observer = _RecordingObserver();
    final previous = Bloc.observer;
    Bloc.observer = observer;
    addTearDown(() => Bloc.observer = previous);
    // Bloc запоминает наблюдателя при создании, поэтому создаём его заново.
    final observed = NotificationsUnreadBloc(inboxRepository: inbox);
    addTearDown(observed.close);
    inbox.unreadCountError = Exception('offline');

    observed.add(const NotificationsUnreadEvent.refreshRequested());
    await pumpEventQueue();

    expect(observer.errors, hasLength(1));
  });

  test('фоновая ошибка репозитория попадает в BlocObserver', () async {
    final observer = _RecordingObserver();
    final previous = Bloc.observer;
    Bloc.observer = observer;
    addTearDown(() => Bloc.observer = previous);
    // Bloc запоминает наблюдателя при создании, поэтому создаём его заново.
    final observed = NotificationsUnreadBloc(inboxRepository: inbox);
    addTearDown(observed.close);

    inbox.errorsController.add((error: StateError('offline'), stackTrace: StackTrace.empty));
    await pumpEventQueue();

    expect(observer.errors.single, isA<StateError>());
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

final class _RecordingObserver extends BlocObserver {
  final List<Object> errors = [];

  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    errors.add(error);
    super.onError(bloc, error, stackTrace);
  }
}
