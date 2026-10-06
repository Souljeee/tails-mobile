# Продуктовая аналитика

Документ описывает, как приложение «Хвостики» отправляет события в AppMetrica и Firebase
Analytics, какие события есть и как добавить новое. Краткая версия правил — в `AGENTS.md`.

## 1. Принципы

- **Одна точка входа.** Весь код вызывает только `TailsAnalytics`. Пакеты `appmetrica_plugin` и
  `firebase_analytics` импортируются только в `core/analytics/sinks/` (проверяет
  `analytics_architecture_test.dart`).
- **Никаких персональных данных.** В событиях нет телефона, имени, названия питомца, текстов
  событий и обращений, кодов и токенов. Параметры — закрытые словари и корзины (`2-3`, `4+`).
  `TailsAnalyticsSanitizer` дополнительно отбрасывает запрещённые ключи, ограничивает число
  параметров (10) и длину строк (100), но это второй рубеж, а не разрешение.
- **Аналитика не ломает приложение.** Отправка не ждётся, сбой приёмника изолирован и пишется в
  журнал (не чаще раза в минуту). Вызов до `configure` безопасен.
- **События отправляются после успеха операции.** Для ошибок есть отдельные `*_failed` с
  закрытой причиной (`AnalyticsReason`). Подробности ошибок остаются у Sentry.
- **Одно место для имён.** Имена и параметры задаются в `TailsAnalyticsEvents`, а не строками
  по коду.

## 2. Архитектура

```text
код приложения ──► TailsAnalytics (фасад) ──► TailsAnalyticsDispatcher
                                                 │  санитайзер
                    ┌────────────────────────────┼───────────────────────┐
                    ▼                            ▼                       ▼
        AppMetricaAnalyticsSink      FirebaseAnalyticsSink      LogAnalyticsSink
        (все окружения, если         (только prod)              (не release,
         задан ключ)                                             журнал trace)
```

Приёмники создаёт `TailsAnalyticsSinkFactory` при старте (`AppRunner.startup()`); сбой или
таймаут инициализации сервиса лишь отключает этот приёмник.

## 3. Настройка окружений

| Окружение | AppMetrica | Firebase Analytics |
|---|---|---|
| `dev`, `staging` | приложение «dev» | выключен |
| `prod` | приложение «prod» | включён |

Ключ AppMetrica передаётся через `--dart-define` и в репозиторий не записывается:

```sh
fvm flutter run --dart-define-from-file=env/.dev.env   # внутри APPMETRICA_API_KEY=<dev-ключ>
fvm flutter build ipa --dart-define=ENVIRONMENT=PROD --dart-define=APPMETRICA_API_KEY=<prod-ключ>
```

Пустой `APPMETRICA_API_KEY` — AppMetrica не подключается (удобно для тестов и локальной
отладки). Для `staging` используется ключ приложения «dev».

Firebase Analytics по умолчанию выключен в нативной конфигурации и включается из кода только в
`prod`: Android — `firebase_analytics_collection_enabled=false`, iOS —
`FIREBASE_ANALYTICS_COLLECTION_ENABLED=false`. Автоматические экраны отключены
(`google_analytics_automatic_screen_reporting_enabled`, `FirebaseAutomaticScreenReportingEnabled`):
экраны отправляет `AnalyticsScreenTracker`.

AppMetrica настроена без отправки сбоев (`crashReporting: false`): ошибки собирает Sentry.

## 4. Пользователь и свойства

`user_id` — внутренний идентификатор из ответа `verify-code` (совпадает с `id` профиля):
`TailsAnalytics.setUser` вызывается сразу после входа, `clearUser` — при выходе, потере сессии и
удалении аккаунта. Бэкенд возвращает `is_new_user` и `user_id` только в `verify-code`.

| Свойство | Тип | Когда обновляется |
|---|---|---|
| `pets_count`, `dogs_count`, `cats_count` | число | после загрузки списка питомцев, добавления и удаления |
| `has_recurring_events` | bool | при создании повторяющегося события или загрузке расписания с повторами (только включается) |
| `push_status` | `granted` / `denied` / `system_blocked` | при результате запроса разрешения и показе баннера «уведомления отключены» |
| `signup_date` | `YYYY-MM-DD` | при регистрации |
| `app_theme` | `system` / `light` / `dark` | при смене темы |

## 5. Каталог событий

Параметры событий — только значения из таблицы. «Источник» — `source`: `navbar_plus`,
`empty_state`, `pet_details`, `calendar`, `push`, `inbox` (в коде подключён `navbar_plus`).

### Экраны

| Событие | Параметры | Где отправляется |
|---|---|---|
| `screen_view` | `screen_name` (имя маршрута в snake_case) | `AnalyticsScreenTracker` |
| `sheet_view` | `sheet_name` | `AnalyticsSheetObserver` (только именованные шторки) |

### Вход и аккаунт

| Событие | Параметры | Где |
|---|---|---|
| `login_code_requested` | `is_resend` | `SendCodeBloc` |
| `login_code_request_failed` | `reason` | `SendCodeBloc` |
| `login_succeeded` | `is_new_user` (если бэкенд передал) | `AuthBloc` |
| `signup_completed` | — (Firebase дополнительно шлёт `sign_up`) | `AuthBloc`, при `is_new_user = true` |
| `login_failed` | `reason` | `AuthBloc` |
| `session_expired` | — | `AuthBloc` (сессия пропала без выхода пользователя) |
| `logout` | — | `AuthBloc` |
| `account_delete_started` | — | `DeleteAccountBloc` |
| `account_deleted` | `pets_count` (корзина) | `DeleteAccountBloc` |
| `account_delete_failed` | `reason` | `DeleteAccountBloc` |

### Питомцы

| Событие | Параметры | Где |
|---|---|---|
| `pet_add_started` | `source` | `PetsScreen` |
| `pet_breed_selected` | — | форма добавления |
| `pet_created` | `pet_type`, `sex`, `is_mixed`, `has_photo`, `is_castrated`, `age_bucket`, `pets_count`, `is_first_pet` | `AddPetBloc` |
| `pet_create_failed` | `reason` | `AddPetBloc` |
| `pet_updated` | `changed` (список полей через запятую), `pet_type` | `EditPetBloc` |
| `pet_deleted` / `pet_delete_failed` | `reason` у второго | `DeletePetBloc` |
| `form_discarded` | `form`, `filled_fields` | `UiDiscardGuard.onDiscarded` |

`pets_count` и `is_first_pet` не передаются, если список питомцев ещё не загружался.

### Расписание

| Событие | Параметры | Где |
|---|---|---|
| `event_create_started` | `source` | `ScheduleScreen` |
| `event_created` | `event_type`, `has_time`, `has_description`, `is_recurring`, `recurrence_period`, `recurrence_interval`, `recurrence_end`, `times_per_day` | `CreateEventBloc` |
| `event_create_failed` | `reason` | `CreateEventBloc` |
| `event_marked_done` | `event_type`, `is_recurring`, `from` (`calendar` / `pet_details`) | `MarkDoneBloc` |
| `event_marked_undone` | `event_type` | `MarkDoneBloc` |
| `schedule_filter_changed` | `filter` (`all` / `pet`) | `ScheduleScreen` |
| `calendar_date_selected` | `is_today` | `ScheduleScreen` |
| `recurrence_opened`, `recurrence_saved` | у второго `recurrence_period`, `recurrence_interval`, `recurrence_end` | форма события |

`is_first_event` в `event_created` не передаётся: приложение не знает, были ли события раньше.

### Уведомления

| Событие | Параметры | Где |
|---|---|---|
| `push_permission_result` | `status` (`granted` / `denied`) | `PushNotificationsBloc` (только при смене результата) |
| `push_opened`, `push_received_foreground` | `type` | `PushNotificationsBloc`, `PushNotificationsRepository` |
| `notifications_disabled_banner_shown` | — | баннеры в настройках и центре уведомлений |
| `notifications_open_system_settings` | — | блоки настроек и центра уведомлений |
| `notification_setting_changed` | `setting`, `enabled` | `NotificationsSettingsBloc` |
| `inbox_opened`, `inbox_read_all` | — | `NotificationsInboxBloc` |
| `inbox_item_opened` | `type` | `NotificationsInboxBloc` |
| `inbox_filter_changed` | `filter` | `NotificationsInboxBloc` |

### Профиль и качество

| Событие | Параметры | Где |
|---|---|---|
| `profile_updated` | `changed` (`name`, `photo`) | `EditProfileBloc` |
| `profile_photo_action` | `action` (`add` / `change` / `remove`) | `EditProfileBloc` |
| `feedback_sent` | `category` | `FeedbackBloc` |
| `feedback_failed` | `reason` | `FeedbackBloc` |
| `legal_link_opened` | `document` (`terms` / `privacy`) | `AboutScreen` |
| `app_setting_changed` | `setting`, `value` | `ProfileThemeRow` |
| `error_state_shown`, `error_retry_tapped` | `screen_name` (+ `reason`) | `UiFetchingError` |
| `empty_state_shown` | `screen_name` | пустые состояния питомцев и центра уведомлений |

`reason` у `error_state_shown` всегда `unknown`: виджет ошибки не знает причины.

## 6. Как добавить событие

1. Добавь фабрику в `TailsAnalyticsEvents` (имя `snake_case`, параметры — закрытый словарь).
2. Вызови `TailsAnalytics.log(...)` **после успешной операции**, обычно в блоке рядом с
   `emit(success)`. Для ошибки используй `*_failed` и `analyticsReasonOf(error)`.
3. Не передавай свободный текст и идентификаторы: только значения enum и корзины.
4. Добавь тест: подключи `RecordingAnalyticsSink` через `TailsAnalytics.configure`, в `tearDown`
   вызови `TailsAnalytics.reset`.
5. Обнови каталог в этом документе.

## 7. Проверка в отладке

В не-release сборках события дублируются в журнал (`LogAnalyticsSink`, уровень `trace`, запись
«Событие аналитики»). В AppMetrica данные появляются с задержкой; для проверки событий dev-приложения
открывайте раздел «События» его отчётов.
