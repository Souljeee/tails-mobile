import 'package:meta/meta.dart';

/// Уровень важности записи журнала.
enum TailsLogLevel {
  /// Технические подробности, нужные только при глубокой отладке.
  trace('T'),

  /// Подробности для отладки (события и состояния BLoC, детали запросов).
  debug('D'),

  /// Нормальные важные события: переходы, запросы, шаги пользовательского сценария.
  info('I'),

  /// Подозрительная ситуация, которая не ломает сценарий.
  warning('W'),

  /// Ошибка операции.
  error('E'),

  /// Критическая ошибка приложения.
  fatal('F');

  const TailsLogLevel(this.shortName);

  /// Однобуквенное обозначение для строки журнала.
  final String shortName;

  /// Не ниже ли этот уровень, чем [other].
  bool isAtLeast(TailsLogLevel other) => index >= other.index;
}

/// Область приложения, к которой относится запись журнала.
///
/// Категория нужна для единообразного формата, фильтрации и тегов во внешних сервисах.
/// Конкретный компонент (например, `PetRepository`) указывается отдельно в `source`.
enum TailsLogCategory {
  /// Запуск, жизненный цикл, инициализация, глобальные ошибки.
  app('APP'),

  /// Переходы между экранами.
  navigation('NAV'),

  /// Сетевые запросы.
  network('NET'),

  /// События, переходы и ошибки BLoC/Cubit.
  bloc('BLOC'),

  /// Важные точки пользовательского сценария. Категория по умолчанию.
  business('BIZ');

  const TailsLogCategory(this.label);

  /// Короткая метка для строки журнала.
  final String label;
}

/// Одна запись журнала.
@immutable
final class TailsLogEvent {
  /// Создаёт запись журнала.
  const TailsLogEvent({
    required this.sequence,
    required this.time,
    required this.level,
    required this.category,
    required this.message,
    this.source,
    this.data = const {},
    this.error,
    this.stackTrace,
    this.report = true,
  });

  /// Порядковый номер записи в рамках запуска приложения.
  final int sequence;

  /// Время создания записи.
  final DateTime time;

  /// Уровень важности.
  final TailsLogLevel level;

  /// Область приложения.
  final TailsLogCategory category;

  /// Текст записи. Переменные значения передаются в [data], а не в текст.
  final String message;

  /// Компонент, создавший запись (например, `PetRepository`).
  final String? source;

  /// Структурированные поля записи.
  final Map<String, Object?> data;

  /// Исключение, связанное с записью.
  final Object? error;

  /// Стек вызовов исключения.
  final StackTrace? stackTrace;

  /// Можно ли отправлять запись во внешний сервис отчётов об ошибках.
  ///
  /// Влияет только на записи уровня `error` и выше; `false` ставят слои, которые
  /// не владеют ошибкой (например, сеть), чтобы одна ошибка не была отправлена дважды.
  final bool report;
}
