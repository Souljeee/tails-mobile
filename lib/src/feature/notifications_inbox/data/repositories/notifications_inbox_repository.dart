import 'dart:async';

import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/utils/background_error.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/data_sources/dtos/inbox_item_dto.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/data_sources/notifications_inbox_remote_data_source.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/models/inbox_item.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

/// «Центр уведомлений»: история уведомлений и число непрочитанных.
///
/// Хранит последнее известное число непрочитанных и сообщает о его изменениях ([unreadCount]):
/// на нём держится бейдж на колокольчике. Когда в открытом приложении приходит push,
/// число обновляется само и приходит событие [incoming], по которому открытый список
/// перезагружается.
class NotificationsInboxRepository {
  NotificationsInboxRepository({
    required NotificationsInboxRemoteDataSource remoteDataSource,
    Stream<Object?> incomingPushes = const Stream.empty(),
    Stream<AuthorizationStatus> authorizationStatus = const Stream.empty(),
  }) : _remote = remoteDataSource {
    _subscriptions
      ..add(incomingPushes.listen((_) => _onIncomingPush()))
      ..add(authorizationStatus.listen(_onAuthorizationChanged));
  }

  final NotificationsInboxRemoteDataSource _remote;

  final StreamController<int> _unreadController = StreamController<int>.broadcast();
  final StreamController<void> _incomingController = StreamController<void>.broadcast();
  final StreamController<BackgroundError> _errorsController = StreamController.broadcast();
  final List<StreamSubscription<Object?>> _subscriptions = [];

  int? _unreadCount;

  /// Последнее известное число непрочитанных; `null`, пока оно не загружалось.
  int? get currentUnreadCount => _unreadCount;

  /// Изменения числа непрочитанных.
  Stream<int> get unreadCount => _unreadController.stream;

  /// В открытом приложении пришёл push: список мог измениться.
  Stream<void> get incoming => _incomingController.stream;

  /// Ошибки фоновых операций ([markReadSilently], обновление числа по push), которые
  /// некому пробросить вызывающему коду.
  Stream<BackgroundError> get errors => _errorsController.stream;

  /// Страница уведомлений; [cursor] — `nextCursor` предыдущей страницы.
  ///
  /// Throws RestClientException или FormatException, если сервер ответил ошибкой
  /// или неожиданным форматом.
  Future<InboxPage> getPage({String? cursor, bool unreadOnly = false}) async {
    final page = await _remote.getNotifications(cursor: cursor, unreadOnly: unreadOnly);

    _setUnreadCount(page.unreadCount);

    return InboxPage(
      items: page.results.map(_toModel).toList(growable: false),
      nextCursor: page.nextCursor,
      unreadCount: page.unreadCount,
    );
  }

  /// Загружает число непрочитанных с сервера и возвращает его.
  Future<int> refreshUnreadCount() async {
    final count = await _remote.getUnreadCount();

    _setUnreadCount(count);

    return count;
  }

  /// Отмечает уведомление прочитанным; возвращает число непрочитанных.
  Future<int> markRead(String id) async {
    final count = await _remote.markRead(id);

    _setUnreadCount(count);

    return count;
  }

  /// Отмечает все уведомления прочитанными.
  Future<void> markAllRead() async => _setUnreadCount(await _remote.markAllRead());

  /// То же, что [markRead], но ошибка не пробрасывается, а уходит в [errors]: для нажатия
  /// на push, где пользователь уже перешёл дальше и показать ошибку некому.
  Future<void> markReadSilently(String id) async {
    try {
      await markRead(id);
    } on Object catch (e, s) {
      _errorsController.add((error: e, stackTrace: s));
    }
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();

    await _unreadController.close();
    await _incomingController.close();
    await _errorsController.close();
  }

  void _onIncomingPush() {
    _incomingController.add(null);
    unawaited(_refreshUnreadCountSilently());
  }

  Future<void> _refreshUnreadCountSilently() async {
    try {
      await refreshUnreadCount();
    } on Object catch (e, s) {
      _errorsController.add((error: e, stackTrace: s));
    }
  }

  void _onAuthorizationChanged(AuthorizationStatus status) {
    // Данные прошлого пользователя не должны попасть на экран следующего.
    if (status != AuthorizationStatus.authorized) {
      _unreadCount = null;
      _unreadController.add(0);
    }
  }

  void _setUnreadCount(int count) {
    if (count == _unreadCount) {
      return;
    }

    _unreadCount = count;
    _unreadController.add(count);
  }

  InboxItem _toModel(InboxItemDto dto) => InboxItem(
    id: dto.id,
    kind: InboxItemKind.fromWire(dto.kind),
    title: dto.title,
    body: dto.body,
    createdAt: DateTime.parse(dto.createdAt).toLocal(),
    isRead: dto.isRead,
    petId: dto.petId,
    eventId: dto.eventId,
    eventType: ScheduleEventTypeEnum.values.asNameMap()[dto.eventType],
    occurrenceDate: dto.occurrenceDate == null ? null : DateTime.tryParse(dto.occurrenceDate!),
  );
}
