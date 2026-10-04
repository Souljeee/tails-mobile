part of 'notifications_unread_bloc.dart';

typedef NotificationsUnreadEventMatch<T, S extends NotificationsUnreadEvent> = T Function(S event);

sealed class NotificationsUnreadEvent extends Equatable {
  const NotificationsUnreadEvent();

  /// Запросить число непрочитанных с сервера.
  const factory NotificationsUnreadEvent.refreshRequested() =
      NotificationsUnreadEvent$RefreshRequested;

  /// Репозиторий сообщил новое число.
  const factory NotificationsUnreadEvent.countChanged({required int count}) =
      NotificationsUnreadEvent$CountChanged;

  T map<T>({
    required NotificationsUnreadEventMatch<T, NotificationsUnreadEvent$RefreshRequested>
    refreshRequested,
    required NotificationsUnreadEventMatch<T, NotificationsUnreadEvent$CountChanged> countChanged,
  }) => switch (this) {
    final NotificationsUnreadEvent$RefreshRequested event => refreshRequested(event),
    final NotificationsUnreadEvent$CountChanged event => countChanged(event),
  };
}

final class NotificationsUnreadEvent$RefreshRequested extends NotificationsUnreadEvent {
  const NotificationsUnreadEvent$RefreshRequested();

  @override
  List<Object?> get props => [];
}

final class NotificationsUnreadEvent$CountChanged extends NotificationsUnreadEvent {
  const NotificationsUnreadEvent$CountChanged({required this.count});

  final int count;

  @override
  List<Object?> get props => [count];
}
