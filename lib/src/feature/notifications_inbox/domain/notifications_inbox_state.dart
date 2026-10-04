part of 'notifications_inbox_bloc.dart';

enum NotificationsInboxStatus { loading, ready, failure }

enum NotificationsInboxFilter { all, unread }

final class NotificationsInboxState extends Equatable {
  const NotificationsInboxState({
    this.status = NotificationsInboxStatus.loading,
    this.filter = NotificationsInboxFilter.all,
    this.items = const [],
    this.nextCursor,
    this.unreadCount = 0,
    this.isLoadingMore = false,
    this.pets = const {},
    this.isBlockedBySystem = false,
    this.actionFailures = 0,
  });

  final NotificationsInboxStatus status;
  final NotificationsInboxFilter filter;

  /// Уведомления выбранного фильтра, от новых к старым.
  final List<InboxItem> items;

  /// Курсор следующей страницы; `null`, если страниц больше нет.
  final String? nextCursor;

  /// Все непрочитанные пользователя, независимо от фильтра и загруженных страниц.
  final int unreadCount;
  final bool isLoadingMore;

  /// Питомцы по id: из них берутся аватар и цвет. Пусто, если загрузить их не удалось.
  final Map<int, PetModel> pets;

  /// Уведомления запрещены в настройках телефона.
  final bool isBlockedBySystem;

  /// Сколько раз не удалось отметить прочитанным; экран показывает ошибку при росте.
  final int actionFailures;

  bool get hasMore => nextCursor != null;

  /// В выбранном фильтре ничего нет.
  bool get isEmpty => status == NotificationsInboxStatus.ready && items.isEmpty;

  NotificationsInboxState copyWith({
    NotificationsInboxStatus? status,
    NotificationsInboxFilter? filter,
    List<InboxItem>? items,
    CopyWithWrapper<String?>? nextCursor,
    int? unreadCount,
    bool? isLoadingMore,
    Map<int, PetModel>? pets,
    bool? isBlockedBySystem,
    int? actionFailures,
  }) => NotificationsInboxState(
    status: status ?? this.status,
    filter: filter ?? this.filter,
    items: items ?? this.items,
    nextCursor: nextCursor != null ? nextCursor.value : this.nextCursor,
    unreadCount: unreadCount ?? this.unreadCount,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    pets: pets ?? this.pets,
    isBlockedBySystem: isBlockedBySystem ?? this.isBlockedBySystem,
    actionFailures: actionFailures ?? this.actionFailures,
  );

  @override
  List<Object?> get props => [
    status,
    filter,
    items,
    nextCursor,
    unreadCount,
    isLoadingMore,
    pets,
    isBlockedBySystem,
    actionFailures,
  ];
}
