part of 'notifications_settings_bloc.dart';

typedef NotificationsSettingsEventMatch<T, S extends NotificationsSettingsEvent> =
    T Function(S event);

sealed class NotificationsSettingsEvent extends Equatable {
  const NotificationsSettingsEvent();

  /// Загрузить настройки и состояние системного разрешения.
  const factory NotificationsSettingsEvent.started() = NotificationsSettingsEvent$Started;

  /// Перепроверить системное разрешение (пользователь мог вернуться из настроек телефона).
  const factory NotificationsSettingsEvent.systemStatusChecked() =
      NotificationsSettingsEvent$SystemStatusChecked;

  const factory NotificationsSettingsEvent.toggled({
    required NotificationCategory category,
    required bool enabled,
  }) = NotificationsSettingsEvent$Toggled;

  const factory NotificationsSettingsEvent.openSettingsRequested() =
      NotificationsSettingsEvent$OpenSettingsRequested;

  T map<T>({
    required NotificationsSettingsEventMatch<T, NotificationsSettingsEvent$Started> started,
    required NotificationsSettingsEventMatch<T, NotificationsSettingsEvent$SystemStatusChecked>
    systemStatusChecked,
    required NotificationsSettingsEventMatch<T, NotificationsSettingsEvent$Toggled> toggled,
    required NotificationsSettingsEventMatch<T, NotificationsSettingsEvent$OpenSettingsRequested>
    openSettingsRequested,
  }) => switch (this) {
    final NotificationsSettingsEvent$Started event => started(event),
    final NotificationsSettingsEvent$SystemStatusChecked event => systemStatusChecked(event),
    final NotificationsSettingsEvent$Toggled event => toggled(event),
    final NotificationsSettingsEvent$OpenSettingsRequested event => openSettingsRequested(event),
  };

  T? mapOrNull<T>({
    NotificationsSettingsEventMatch<T, NotificationsSettingsEvent$Started>? started,
    NotificationsSettingsEventMatch<T, NotificationsSettingsEvent$SystemStatusChecked>?
    systemStatusChecked,
    NotificationsSettingsEventMatch<T, NotificationsSettingsEvent$Toggled>? toggled,
    NotificationsSettingsEventMatch<T, NotificationsSettingsEvent$OpenSettingsRequested>?
    openSettingsRequested,
  }) => map<T?>(
    started: started ?? (_) => null,
    systemStatusChecked: systemStatusChecked ?? (_) => null,
    toggled: toggled ?? (_) => null,
    openSettingsRequested: openSettingsRequested ?? (_) => null,
  );
}

final class NotificationsSettingsEvent$Started extends NotificationsSettingsEvent {
  const NotificationsSettingsEvent$Started();

  @override
  List<Object?> get props => [];
}

final class NotificationsSettingsEvent$SystemStatusChecked extends NotificationsSettingsEvent {
  const NotificationsSettingsEvent$SystemStatusChecked();

  @override
  List<Object?> get props => [];
}

final class NotificationsSettingsEvent$Toggled extends NotificationsSettingsEvent {
  const NotificationsSettingsEvent$Toggled({required this.category, required this.enabled});

  final NotificationCategory category;
  final bool enabled;

  @override
  List<Object?> get props => [category, enabled];
}

final class NotificationsSettingsEvent$OpenSettingsRequested extends NotificationsSettingsEvent {
  const NotificationsSettingsEvent$OpenSettingsRequested();

  @override
  List<Object?> get props => [];
}
