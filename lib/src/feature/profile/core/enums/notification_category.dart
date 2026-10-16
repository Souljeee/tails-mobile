/// Категория уведомлений в настройках профиля: совпадает с группой типов события в форме
/// создания события.
///
/// [apiKey] — ключ в `GET/PATCH /profile/notification-settings/`.
enum NotificationCategory {
  health('health'),
  care('care'),
  daily('daily'),
  other('other');

  const NotificationCategory(this.apiKey);

  final String apiKey;
}
