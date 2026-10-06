import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';

/// Причины ошибок и отказов. Одно закрытое множество на все события.
enum AnalyticsReason {
  /// Нет сети.
  network('network'),

  /// Таймаут запроса.
  timeout('timeout'),

  /// Ответ сервера с ошибкой 5xx.
  server('server'),

  /// Данные не прошли проверку.
  validation('validation'),

  /// Неверный код.
  invalidCode('invalid_code'),

  /// Слишком много попыток.
  rateLimited('rate_limited'),

  /// Нет доступа.
  unauthorized('unauthorized'),

  /// Не найдено.
  notFound('not_found'),

  /// Прочее.
  unknown('unknown');

  const AnalyticsReason(this.value);

  /// Значение параметра `reason`.
  final String value;
}

/// Откуда начато действие.
enum AnalyticsSource {
  /// Кнопка «+» в нижней панели.
  navbarPlus('navbar_plus'),

  /// Пустое состояние экрана.
  emptyState('empty_state'),

  /// Экран питомца.
  petDetails('pet_details'),

  /// Календарь.
  calendar('calendar'),

  /// Push-уведомление.
  push('push'),

  /// Центр уведомлений.
  inbox('inbox');

  const AnalyticsSource(this.value);

  /// Значение параметра `source`.
  final String value;
}

/// Каталог событий аналитики: единственное место, где задаются имена и параметры.
///
/// Параметры — закрытые словари и корзины, без имён, описаний, телефонов и другого
/// свободного текста. Новое событие добавляйте сюда и в `docs/analytics.md`.
abstract final class TailsAnalyticsEvents {
  /// Имя события просмотра экрана (Firebase отправляет его через `logScreenView`).
  static const screenViewName = 'screen_view';

  /// Имя события завершения регистрации (Firebase дополнительно шлёт `sign_up`).
  static const signupCompletedName = 'signup_completed';

  /// Корзина количества: `0`, `1`, `2-3`, `4+`.
  static String countBucket(int count) => switch (count) {
    <= 0 => '0',
    1 => '1',
    2 || 3 => '2-3',
    _ => '4+',
  };

  /// Корзина возраста в годах: `<1`, `1-3`, `4-7`, `8+`.
  static String ageBucket(int years) => switch (years) {
    < 1 => '<1',
    <= 3 => '1-3',
    <= 7 => '4-7',
    _ => '8+',
  };

  /// Корзина возраста по дате рождения.
  static String ageBucketOf(DateTime birthday, {required DateTime now}) {
    var years = now.year - birthday.year;
    if (now.month < birthday.month || (now.month == birthday.month && now.day < birthday.day)) {
      years--;
    }

    return ageBucket(years);
  }

  /// Переводит `lowerCamelCase` в `snake_case` (для имён enum).
  static String snake(String value) =>
      value.replaceAllMapped(RegExp('[A-Z]'), (match) => '_${match[0]!.toLowerCase()}');

  // --- Навигация ---

  /// Открыт экран.
  static TailsAnalyticsEvent screenView(String screenName) =>
      TailsAnalyticsEvent(screenViewName, parameters: {'screen_name': screenName});

  /// Открыт нижний лист или диалог.
  static TailsAnalyticsEvent sheetView(String sheetName) =>
      TailsAnalyticsEvent('sheet_view', parameters: {'sheet_name': sheetName});

  // --- Вход и аккаунт ---

  /// Запрошен код входа.
  static TailsAnalyticsEvent loginCodeRequested({required bool isResend}) =>
      TailsAnalyticsEvent('login_code_requested', parameters: {'is_resend': isResend});

  /// Не удалось запросить код.
  static TailsAnalyticsEvent loginCodeRequestFailed(AnalyticsReason reason) =>
      TailsAnalyticsEvent('login_code_request_failed', parameters: {'reason': reason.value});

  /// Вход выполнен. [isNewUser] — `null`, если бэкенд не сообщил признак.
  static TailsAnalyticsEvent loginSucceeded({bool? isNewUser}) => TailsAnalyticsEvent(
    'login_succeeded',
    parameters: {if (isNewUser != null) 'is_new_user': isNewUser},
  );

  /// Регистрация завершена.
  static const signupCompleted = TailsAnalyticsEvent(signupCompletedName);

  /// Вход не удался.
  static TailsAnalyticsEvent loginFailed(AnalyticsReason reason) =>
      TailsAnalyticsEvent('login_failed', parameters: {'reason': reason.value});

  /// Сессия истекла.
  static const sessionExpired = TailsAnalyticsEvent('session_expired');

  /// Пользователь вышел.
  static const logout = TailsAnalyticsEvent('logout');

  /// Начато удаление аккаунта.
  static const accountDeleteStarted = TailsAnalyticsEvent('account_delete_started');

  /// Аккаунт удалён.
  static TailsAnalyticsEvent accountDeleted({required int petsCount}) =>
      TailsAnalyticsEvent('account_deleted', parameters: {'pets_count': countBucket(petsCount)});

  /// Не удалось удалить аккаунт.
  static TailsAnalyticsEvent accountDeleteFailed(AnalyticsReason reason) =>
      TailsAnalyticsEvent('account_delete_failed', parameters: {'reason': reason.value});

  // --- Питомцы ---

  /// Начато добавление питомца.
  static TailsAnalyticsEvent petAddStarted(AnalyticsSource source) =>
      TailsAnalyticsEvent('pet_add_started', parameters: {'source': source.value});

  /// Выбрана порода.
  static const petBreedSelected = TailsAnalyticsEvent('pet_breed_selected');

  /// Питомец создан.
  static TailsAnalyticsEvent petCreated({
    required String petType,
    required String sex,
    required bool isMixed,
    required bool hasPhoto,
    required bool isCastrated,
    required String ageBucket,
    int? petsCount,
    bool? isFirstPet,
  }) => TailsAnalyticsEvent(
    'pet_created',
    parameters: {
      'pet_type': petType,
      'sex': sex,
      'is_mixed': isMixed,
      'has_photo': hasPhoto,
      'is_castrated': isCastrated,
      'age_bucket': ageBucket,
      if (petsCount != null) 'pets_count': countBucket(petsCount),
      if (isFirstPet != null) 'is_first_pet': isFirstPet,
    },
  );

  /// Не удалось создать питомца.
  static TailsAnalyticsEvent petCreateFailed(AnalyticsReason reason) =>
      TailsAnalyticsEvent('pet_create_failed', parameters: {'reason': reason.value});

  /// Питомец изменён. [changed] — список изменённых полей через запятую (закрытый словарь).
  static TailsAnalyticsEvent petUpdated({required String changed, required String petType}) =>
      TailsAnalyticsEvent('pet_updated', parameters: {'changed': changed, 'pet_type': petType});

  /// Питомец удалён.
  static const petDeleted = TailsAnalyticsEvent('pet_deleted');

  /// Не удалось удалить питомца.
  static TailsAnalyticsEvent petDeleteFailed(AnalyticsReason reason) =>
      TailsAnalyticsEvent('pet_delete_failed', parameters: {'reason': reason.value});

  /// Форма закрыта без сохранения.
  static TailsAnalyticsEvent formDiscarded({required String form, required int filledFields}) =>
      TailsAnalyticsEvent(
        'form_discarded',
        parameters: {'form': form, 'filled_fields': filledFields},
      );

  // --- События и расписание ---

  /// Начато создание события.
  static TailsAnalyticsEvent eventCreateStarted(AnalyticsSource source) =>
      TailsAnalyticsEvent('event_create_started', parameters: {'source': source.value});

  /// Событие создано.
  static TailsAnalyticsEvent eventCreated({
    required String eventType,
    required bool hasTime,
    required bool hasDescription,
    required bool isRecurring,
    bool? isFirstEvent,
    String? recurrencePeriod,
    int? recurrenceInterval,
    String? recurrenceEnd,
    int? timesPerDay,
  }) => TailsAnalyticsEvent(
    'event_created',
    parameters: {
      'event_type': eventType,
      'has_time': hasTime,
      'has_description': hasDescription,
      'is_recurring': isRecurring,
      if (recurrencePeriod != null) 'recurrence_period': recurrencePeriod,
      if (recurrenceInterval != null) 'recurrence_interval': recurrenceInterval,
      if (recurrenceEnd != null) 'recurrence_end': recurrenceEnd,
      if (timesPerDay != null) 'times_per_day': timesPerDay,
      if (isFirstEvent != null) 'is_first_event': isFirstEvent,
    },
  );

  /// Не удалось создать событие.
  static TailsAnalyticsEvent eventCreateFailed(AnalyticsReason reason) =>
      TailsAnalyticsEvent('event_create_failed', parameters: {'reason': reason.value});

  /// Событие отмечено выполненным.
  static TailsAnalyticsEvent eventMarkedDone({
    required String eventType,
    required bool isRecurring,
    required String from,
  }) => TailsAnalyticsEvent(
    'event_marked_done',
    parameters: {'event_type': eventType, 'is_recurring': isRecurring, 'from': from},
  );

  /// Отметка о выполнении снята.
  static TailsAnalyticsEvent eventMarkedUndone({required String eventType}) =>
      TailsAnalyticsEvent('event_marked_undone', parameters: {'event_type': eventType});

  /// Изменён фильтр расписания.
  static TailsAnalyticsEvent scheduleFilterChanged(String filter) =>
      TailsAnalyticsEvent('schedule_filter_changed', parameters: {'filter': filter});

  /// Выбрана дата в календаре.
  static TailsAnalyticsEvent calendarDateSelected({required bool isToday}) =>
      TailsAnalyticsEvent('calendar_date_selected', parameters: {'is_today': isToday});

  /// Открыт редактор повторения.
  static const recurrenceOpened = TailsAnalyticsEvent('recurrence_opened');

  /// Повторение сохранено.
  static TailsAnalyticsEvent recurrenceSaved({
    required String period,
    required int interval,
    required String end,
  }) => TailsAnalyticsEvent(
    'recurrence_saved',
    parameters: {
      'recurrence_period': period,
      'recurrence_interval': interval,
      'recurrence_end': end,
    },
  );

  // --- Уведомления ---

  /// Ответ на запрос разрешения push.
  static TailsAnalyticsEvent pushPermissionResult({required String status}) =>
      TailsAnalyticsEvent('push_permission_result', parameters: {'status': status});

  /// Открыто push-уведомление.
  static TailsAnalyticsEvent pushOpened({required String type}) =>
      TailsAnalyticsEvent('push_opened', parameters: {'type': type});

  /// Push получен, пока приложение открыто.
  static TailsAnalyticsEvent pushReceivedForeground({required String type}) =>
      TailsAnalyticsEvent('push_received_foreground', parameters: {'type': type});

  /// Показан баннер «уведомления отключены».
  static const notificationsDisabledBannerShown = TailsAnalyticsEvent(
    'notifications_disabled_banner_shown',
  );

  /// Нажато «открыть системные настройки».
  static const notificationsOpenSystemSettings = TailsAnalyticsEvent(
    'notifications_open_system_settings',
  );

  /// Изменена настройка уведомлений.
  static TailsAnalyticsEvent notificationSettingChanged({
    required String setting,
    required bool enabled,
  }) => TailsAnalyticsEvent(
    'notification_setting_changed',
    parameters: {'setting': setting, 'enabled': enabled},
  );

  /// Открыт центр уведомлений.
  static const inboxOpened = TailsAnalyticsEvent('inbox_opened');

  /// Открыто уведомление из центра.
  static TailsAnalyticsEvent inboxItemOpened({required String type}) =>
      TailsAnalyticsEvent('inbox_item_opened', parameters: {'type': type});

  /// Изменён фильтр центра уведомлений.
  static TailsAnalyticsEvent inboxFilterChanged(String filter) =>
      TailsAnalyticsEvent('inbox_filter_changed', parameters: {'filter': filter});

  /// Нажато «прочитать все».
  static const inboxReadAll = TailsAnalyticsEvent('inbox_read_all');

  // --- Профиль и настройки ---

  /// Профиль изменён.
  static TailsAnalyticsEvent profileUpdated({required String changed}) =>
      TailsAnalyticsEvent('profile_updated', parameters: {'changed': changed});

  /// Действие с фото профиля: `add`, `change`, `remove`.
  static TailsAnalyticsEvent profilePhotoAction(String action) =>
      TailsAnalyticsEvent('profile_photo_action', parameters: {'action': action});

  /// Обратная связь отправлена.
  static TailsAnalyticsEvent feedbackSent({required String category}) =>
      TailsAnalyticsEvent('feedback_sent', parameters: {'category': category});

  /// Не удалось отправить обратную связь.
  static TailsAnalyticsEvent feedbackFailed(AnalyticsReason reason) =>
      TailsAnalyticsEvent('feedback_failed', parameters: {'reason': reason.value});

  /// Открыта юридическая ссылка: `terms`, `privacy`.
  static TailsAnalyticsEvent legalLinkOpened(String document) =>
      TailsAnalyticsEvent('legal_link_opened', parameters: {'document': document});

  /// Изменена настройка приложения.
  static TailsAnalyticsEvent appSettingChanged({required String setting, required String value}) =>
      TailsAnalyticsEvent('app_setting_changed', parameters: {'setting': setting, 'value': value});

  // --- Качество ---

  /// Показано состояние ошибки.
  static TailsAnalyticsEvent errorStateShown({
    required String screen,
    required AnalyticsReason reason,
  }) => TailsAnalyticsEvent(
    'error_state_shown',
    parameters: {'screen_name': screen, 'reason': reason.value},
  );

  /// Нажата «повторить» на экране ошибки.
  static TailsAnalyticsEvent errorRetryTapped({required String screen}) =>
      TailsAnalyticsEvent('error_retry_tapped', parameters: {'screen_name': screen});

  /// Показано пустое состояние.
  static TailsAnalyticsEvent emptyStateShown({required String screen}) =>
      TailsAnalyticsEvent('empty_state_shown', parameters: {'screen_name': screen});
}
