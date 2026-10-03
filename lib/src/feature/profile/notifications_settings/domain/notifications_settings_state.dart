part of 'notifications_settings_bloc.dart';

enum NotificationsSettingsStatus { loading, ready, failure }

class NotificationsSettingsState extends Equatable {
  const NotificationsSettingsState({
    this.status = NotificationsSettingsStatus.loading,
    this.settings,
    this.isBlockedBySystem = false,
    this.savingCategories = const {},
    this.saveFailures = 0,
  });

  final NotificationsSettingsStatus status;

  /// Настройки, которые сейчас видит пользователь (с учётом ещё не подтверждённых переключений).
  final NotificationSettingsModel? settings;

  /// Уведомления запрещены в настройках телефона.
  final bool isBlockedBySystem;

  /// Категории, изменения которых ещё отправляются на сервер.
  final Set<NotificationCategory> savingCategories;

  /// Сколько раз не удалось сохранить переключатель; экран показывает ошибку при росте.
  final int saveFailures;

  NotificationsSettingsState copyWith({
    NotificationsSettingsStatus? status,
    NotificationSettingsModel? settings,
    bool? isBlockedBySystem,
    Set<NotificationCategory>? savingCategories,
    int? saveFailures,
  }) => NotificationsSettingsState(
    status: status ?? this.status,
    settings: settings ?? this.settings,
    isBlockedBySystem: isBlockedBySystem ?? this.isBlockedBySystem,
    savingCategories: savingCategories ?? this.savingCategories,
    saveFailures: saveFailures ?? this.saveFailures,
  );

  @override
  List<Object?> get props => [status, settings, isBlockedBySystem, savingCategories, saveFailures];
}
