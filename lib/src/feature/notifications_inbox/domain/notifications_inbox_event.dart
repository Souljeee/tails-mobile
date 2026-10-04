part of 'notifications_inbox_bloc.dart';

typedef NotificationsInboxEventMatch<T, S extends NotificationsInboxEvent> = T Function(S event);

sealed class NotificationsInboxEvent extends Equatable {
  const NotificationsInboxEvent();

  /// Первая загрузка списка, питомцев и состояния системного разрешения.
  const factory NotificationsInboxEvent.started() = NotificationsInboxEvent$Started;

  /// Тихо обновить список (pull-to-refresh, push, возврат в приложение).
  const factory NotificationsInboxEvent.refreshRequested({Completer<void>? completer}) =
      NotificationsInboxEvent$RefreshRequested;

  const factory NotificationsInboxEvent.filterChanged({required NotificationsInboxFilter filter}) =
      NotificationsInboxEvent$FilterChanged;

  /// Подгрузить следующую страницу.
  const factory NotificationsInboxEvent.loadMoreRequested() =
      NotificationsInboxEvent$LoadMoreRequested;

  /// Пользователь открыл уведомление: оно становится прочитанным.
  const factory NotificationsInboxEvent.itemOpened({required String id}) =
      NotificationsInboxEvent$ItemOpened;

  const factory NotificationsInboxEvent.readAllRequested() =
      NotificationsInboxEvent$ReadAllRequested;

  /// Перепроверить системное разрешение (пользователь мог вернуться из настроек телефона).
  const factory NotificationsInboxEvent.systemStatusChecked() =
      NotificationsInboxEvent$SystemStatusChecked;

  /// Открыть системные настройки уведомлений.
  const factory NotificationsInboxEvent.openSettingsRequested() =
      NotificationsInboxEvent$OpenSettingsRequested;

  /// Репозиторий сообщил новое число непрочитанных.
  const factory NotificationsInboxEvent.unreadCountChanged({required int count}) =
      NotificationsInboxEvent$UnreadCountChanged;

  T map<T>({
    required NotificationsInboxEventMatch<T, NotificationsInboxEvent$Started> started,
    required NotificationsInboxEventMatch<T, NotificationsInboxEvent$RefreshRequested>
    refreshRequested,
    required NotificationsInboxEventMatch<T, NotificationsInboxEvent$FilterChanged> filterChanged,
    required NotificationsInboxEventMatch<T, NotificationsInboxEvent$LoadMoreRequested>
    loadMoreRequested,
    required NotificationsInboxEventMatch<T, NotificationsInboxEvent$ItemOpened> itemOpened,
    required NotificationsInboxEventMatch<T, NotificationsInboxEvent$ReadAllRequested>
    readAllRequested,
    required NotificationsInboxEventMatch<T, NotificationsInboxEvent$SystemStatusChecked>
    systemStatusChecked,
    required NotificationsInboxEventMatch<T, NotificationsInboxEvent$OpenSettingsRequested>
    openSettingsRequested,
    required NotificationsInboxEventMatch<T, NotificationsInboxEvent$UnreadCountChanged>
    unreadCountChanged,
  }) => switch (this) {
    final NotificationsInboxEvent$Started event => started(event),
    final NotificationsInboxEvent$RefreshRequested event => refreshRequested(event),
    final NotificationsInboxEvent$FilterChanged event => filterChanged(event),
    final NotificationsInboxEvent$LoadMoreRequested event => loadMoreRequested(event),
    final NotificationsInboxEvent$ItemOpened event => itemOpened(event),
    final NotificationsInboxEvent$ReadAllRequested event => readAllRequested(event),
    final NotificationsInboxEvent$SystemStatusChecked event => systemStatusChecked(event),
    final NotificationsInboxEvent$OpenSettingsRequested event => openSettingsRequested(event),
    final NotificationsInboxEvent$UnreadCountChanged event => unreadCountChanged(event),
  };
}

final class NotificationsInboxEvent$Started extends NotificationsInboxEvent {
  const NotificationsInboxEvent$Started();

  @override
  List<Object?> get props => [];
}

final class NotificationsInboxEvent$RefreshRequested extends NotificationsInboxEvent {
  const NotificationsInboxEvent$RefreshRequested({this.completer});

  /// Завершается, когда обработка закончена (для pull-to-refresh).
  final Completer<void>? completer;

  @override
  List<Object?> get props => [];
}

final class NotificationsInboxEvent$FilterChanged extends NotificationsInboxEvent {
  const NotificationsInboxEvent$FilterChanged({required this.filter});

  final NotificationsInboxFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class NotificationsInboxEvent$LoadMoreRequested extends NotificationsInboxEvent {
  const NotificationsInboxEvent$LoadMoreRequested();

  @override
  List<Object?> get props => [];
}

final class NotificationsInboxEvent$ItemOpened extends NotificationsInboxEvent {
  const NotificationsInboxEvent$ItemOpened({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

final class NotificationsInboxEvent$ReadAllRequested extends NotificationsInboxEvent {
  const NotificationsInboxEvent$ReadAllRequested();

  @override
  List<Object?> get props => [];
}

final class NotificationsInboxEvent$SystemStatusChecked extends NotificationsInboxEvent {
  const NotificationsInboxEvent$SystemStatusChecked();

  @override
  List<Object?> get props => [];
}

final class NotificationsInboxEvent$UnreadCountChanged extends NotificationsInboxEvent {
  const NotificationsInboxEvent$UnreadCountChanged({required this.count});

  final int count;

  @override
  List<Object?> get props => [count];
}

final class NotificationsInboxEvent$OpenSettingsRequested extends NotificationsInboxEvent {
  const NotificationsInboxEvent$OpenSettingsRequested();

  @override
  List<Object?> get props => [];
}
