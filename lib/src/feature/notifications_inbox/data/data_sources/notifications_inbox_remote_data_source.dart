import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/data_sources/dtos/inbox_item_dto.dart';

/// Эндпоинты «Центра уведомлений».
class NotificationsInboxRemoteDataSource {
  const NotificationsInboxRemoteDataSource({required RestClient restClient})
    : _restClient = restClient;

  final RestClient _restClient;

  /// Размер страницы по умолчанию.
  static const int pageSize = 30;

  /// Страница уведомлений от новых к старым: `GET /notifications/`.
  ///
  /// [cursor] — `next_cursor` предыдущей страницы; без него загружается первая.
  Future<InboxPageDto> getNotifications({
    String? cursor,
    bool unreadOnly = false,
    int limit = pageSize,
  }) async {
    final response = await _restClient.get(
      '/notifications/',
      queryParams: {
        'limit': limit.toString(),
        if (cursor != null) 'cursor': cursor,
        if (unreadOnly) 'unread': 'true',
      },
    );

    return InboxPageDto.fromJson(_asMap(response));
  }

  /// Число непрочитанных: `GET /notifications/unread-count/`.
  Future<int> getUnreadCount() async =>
      _unreadCountOf(await _restClient.get('/notifications/unread-count/'));

  /// Отмечает уведомление прочитанным и возвращает число непрочитанных.
  Future<int> markRead(String id) async =>
      _unreadCountOf(await _restClient.post('/notifications/$id/read/', body: const {}));

  /// Отмечает все прочитанными: `POST /notifications/read-all/`.
  Future<int> markAllRead() async =>
      _unreadCountOf(await _restClient.post('/notifications/read-all/', body: const {}));

  int _unreadCountOf(Object? response) {
    final count = _asMap(response)['unread_count'];

    if (count is int) {
      return count;
    }

    throw const FormatException('В ответе нет unread_count');
  }

  Map<String, Object?> _asMap(Object? response) {
    if (response is Map<String, Object?>) {
      return response;
    }

    throw const FormatException('Некорректный ответ центра уведомлений');
  }
}
