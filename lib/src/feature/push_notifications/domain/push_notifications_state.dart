part of 'push_notifications_bloc.dart';

enum PushNotificationsStatus {
  /// Пользователь не авторизован или подключение ещё не начиналось.
  idle,

  connecting,

  /// Разрешение выдано, устройство зарегистрировано.
  connected,

  /// Уведомления запрещены в настройках телефона.
  permissionDenied,

  /// Firebase не настроен или токен недоступен.
  unavailable,

  /// Не удалось зарегистрировать устройство на сервере.
  failure,
}

final class PushNotificationsState extends Equatable {
  const PushNotificationsState({
    this.status = PushNotificationsStatus.idle,
    this.lastOpened,
    this.openedCount = 0,
  });

  final PushNotificationsStatus status;

  /// Последнее открытое уведомление; [openedCount] растёт при каждом нажатии,
  /// чтобы повторное нажатие на такое же уведомление тоже замечалось.
  final PushNotification? lastOpened;
  final int openedCount;

  PushNotificationsState copyWith({
    PushNotificationsStatus? status,
    PushNotification? lastOpened,
    int? openedCount,
  }) => PushNotificationsState(
    status: status ?? this.status,
    lastOpened: lastOpened ?? this.lastOpened,
    openedCount: openedCount ?? this.openedCount,
  );

  @override
  List<Object?> get props => [status, lastOpened, openedCount];
}
