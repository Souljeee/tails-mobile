part of 'push_notifications_bloc.dart';

typedef PushNotificationsEventMatch<T, S extends PushNotificationsEvent> = T Function(S event);

sealed class PushNotificationsEvent extends Equatable {
  const PushNotificationsEvent();

  /// Изменился статус авторизации (в том числе при запуске приложения).
  const factory PushNotificationsEvent.authorizationChanged({required AuthorizationStatus status}) =
      PushNotificationsEvent$AuthorizationChanged;

  /// Пользователь нажал на уведомление.
  const factory PushNotificationsEvent.notificationOpened({
    required PushNotification notification,
  }) = PushNotificationsEvent$NotificationOpened;

  T map<T>({
    required PushNotificationsEventMatch<T, PushNotificationsEvent$AuthorizationChanged>
    authorizationChanged,
    required PushNotificationsEventMatch<T, PushNotificationsEvent$NotificationOpened>
    notificationOpened,
  }) => switch (this) {
    final PushNotificationsEvent$AuthorizationChanged event => authorizationChanged(event),
    final PushNotificationsEvent$NotificationOpened event => notificationOpened(event),
  };
}

final class PushNotificationsEvent$AuthorizationChanged extends PushNotificationsEvent {
  const PushNotificationsEvent$AuthorizationChanged({required this.status});

  final AuthorizationStatus status;

  @override
  List<Object?> get props => [status];
}

final class PushNotificationsEvent$NotificationOpened extends PushNotificationsEvent {
  const PushNotificationsEvent$NotificationOpened({required this.notification});

  final PushNotification notification;

  @override
  List<Object?> get props => [notification];
}
