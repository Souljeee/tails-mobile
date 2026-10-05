import 'dart:async';

import 'package:tails_mobile/src/core/utils/background_error.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/models/inbox_item.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/notifications_inbox_repository.dart';

/// Уведомление для тестов; время по умолчанию — полдень 4 октября 2026.
InboxItem fakeInboxItem(
  String id, {
  bool isRead = false,
  DateTime? createdAt,
  int? petId,
  String title = 'Пора дать лекарство',
  String body = 'Таблетка',
  InboxItemKind kind = InboxItemKind.event,
}) => InboxItem(
  id: id,
  kind: kind,
  title: title,
  body: body,
  createdAt: createdAt ?? DateTime(2026, 10, 4, 12),
  isRead: isRead,
  petId: petId,
);

/// Подмена [NotificationsInboxRepository]: отдаёт заранее заданные страницы, события шлются вручную.
///
/// Серверное состояние хранится в [items]: страницы режутся по [pageSize], прочитанные
/// отсекаются при `unreadOnly`, `markRead` меняет [items] и число непрочитанных.
class FakeNotificationsInboxRepository implements NotificationsInboxRepository {
  FakeNotificationsInboxRepository({List<InboxItem> items = const []}) : items = [...items];

  List<InboxItem> items;
  int pageSize = 30;

  final calls = <String>[];

  /// Если задан, соответствующий вызов завершается ошибкой.
  Exception? getPageError;
  Exception? markReadError;
  Exception? markAllReadError;
  Exception? unreadCountError;

  /// Если задан, ответ [getPage] ждёт этого completer.
  Completer<void>? getPageGate;

  final unreadController = StreamController<int>.broadcast();
  final incomingController = StreamController<void>.broadcast();
  final errorsController = StreamController<BackgroundError>.broadcast();

  int get _unread => items.where((item) => !item.isRead).length;

  @override
  int? get currentUnreadCount => _unread;

  @override
  Stream<int> get unreadCount => unreadController.stream;

  @override
  Stream<void> get incoming => incomingController.stream;

  @override
  Stream<BackgroundError> get errors => errorsController.stream;

  @override
  Future<InboxPage> getPage({String? cursor, bool unreadOnly = false}) async {
    calls.add('getPage(cursor: $cursor, unreadOnly: $unreadOnly)');

    await getPageGate?.future;

    if (getPageError != null) {
      throw getPageError!;
    }

    final source = unreadOnly ? items.where((item) => !item.isRead).toList() : items;
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = start + pageSize;

    return InboxPage(
      items: source.sublist(start, end > source.length ? source.length : end),
      nextCursor: end < source.length ? '$end' : null,
      unreadCount: _unread,
    );
  }

  @override
  Future<int> refreshUnreadCount() async {
    calls.add('refreshUnreadCount');

    if (unreadCountError != null) {
      throw unreadCountError!;
    }

    return _unread;
  }

  @override
  Future<int> markRead(String id) async {
    calls.add('markRead($id)');

    if (markReadError != null) {
      throw markReadError!;
    }

    items = [for (final item in items) item.id == id ? item.copyWith(isRead: true) : item];

    return _unread;
  }

  @override
  Future<void> markAllRead() async {
    calls.add('markAllRead');

    if (markAllReadError != null) {
      throw markAllReadError!;
    }

    items = [for (final item in items) item.copyWith(isRead: true)];
  }

  @override
  Future<void> markReadSilently(String id) async {
    try {
      await markRead(id);
    } on Object {
      // как в настоящем репозитории: ошибка только в лог
    }
  }

  @override
  Future<void> dispose() async {
    await unreadController.close();
    await incomingController.close();
    await errorsController.close();
  }
}
