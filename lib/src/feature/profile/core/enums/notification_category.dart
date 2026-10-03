/// Категория уведомлений в настройках профиля.
///
/// [apiKey] — ключ в `GET/PATCH /profile/notification-settings/`.
enum NotificationCategory {
  walks('walks'),
  feeding('feeding'),
  medications('medications'),
  vaccinations('vaccinations'),
  vetVisits('vet_visits');

  const NotificationCategory(this.apiKey);

  final String apiKey;
}
