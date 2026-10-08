/// Событие продуктовой аналитики: имя и закрытый набор параметров.
///
/// Создавайте события только через каталог `TailsAnalyticsEvents`, а не вручную,
/// чтобы имена и значения параметров не расходились между экранами.
final class TailsAnalyticsEvent {
  /// Создаёт событие.
  const TailsAnalyticsEvent(this.name, {this.parameters = const {}});

  /// Имя в snake_case, например `pet_created`.
  final String name;

  /// Параметры события. Допустимы строки, числа и bool.
  final Map<String, Object> parameters;

  @override
  String toString() => 'TailsAnalyticsEvent($name, $parameters)';
}

/// Свойства пользователя, которые отправляются в сервисы аналитики.
enum TailsAnalyticsUserProperty {
  /// Число питомцев (число).
  petsCount('pets_count'),

  /// Число собак (число).
  dogsCount('dogs_count'),

  /// Число кошек (число).
  catsCount('cats_count'),

  /// Есть ли повторяющиеся события (bool).
  hasRecurringEvents('has_recurring_events'),

  /// Состояние push: `granted`, `denied`, `system_blocked` (строка).
  pushStatus('push_status'),

  /// Дата регистрации `YYYY-MM-DD` (строка).
  signupDate('signup_date'),

  /// Тема оформления (строка).
  appTheme('app_theme');

  const TailsAnalyticsUserProperty(this.key);

  /// Имя свойства во внешних сервисах.
  final String key;
}
