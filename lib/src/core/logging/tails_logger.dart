import 'dart:developer' as developer;

import 'package:clock/clock.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sink.dart';

/// Единая точка записи журнала приложения.
///
/// Статический API нужен потому, что журнал используется там, где DI ещё нет
/// (ошибки инициализации), и в глобальных наблюдателях. Реальная работа выполняется
/// в [TailsLogDispatcher], который в тестах создаётся напрямую.
///
/// ```dart
/// TailsLogger.info(
///   'Питомец открыт',
///   category: TailsLogCategory.business,
///   data: {'petId': petId},
/// );
/// TailsLogger.error('Не удалось загрузить питомца', error: e, stackTrace: s);
/// ```
///
/// Переменные значения передавайте в `data`, а не в текст сообщения: поля проходят
/// через санитайзер чувствительных данных, а свободный текст — нет.
abstract final class TailsLogger {
  static TailsLogDispatcher _dispatcher = TailsLogDispatcher();

  /// Подключает получателей записей. Вызывается один раз при старте приложения.
  static void configure({required List<TailsLogSink> sinks}) {
    _dispatcher = TailsLogDispatcher(sinks: sinks);
  }

  /// Отключает всех получателей. Нужен тестам: `addTearDown(TailsLogger.reset)`.
  static void reset() {
    _dispatcher = TailsLogDispatcher();
  }

  /// Нужна ли кому-то из получателей запись с таким [level] и [category].
  ///
  /// Используйте, чтобы не собирать дорогие данные (например, тело ответа) впустую.
  static bool isEnabled(TailsLogLevel level, TailsLogCategory category) =>
      _dispatcher.isEnabled(level, category);

  /// Технические подробности.
  static void trace(
    String message, {
    TailsLogCategory category = TailsLogCategory.business,
    String? source,
    Map<String, Object?>? data,
  }) =>
      _dispatcher.log(TailsLogLevel.trace, message, category: category, source: source, data: data);

  /// Подробности для отладки.
  static void debug(
    String message, {
    TailsLogCategory category = TailsLogCategory.business,
    String? source,
    Map<String, Object?>? data,
  }) =>
      _dispatcher.log(TailsLogLevel.debug, message, category: category, source: source, data: data);

  /// Нормальное важное событие.
  static void info(
    String message, {
    TailsLogCategory category = TailsLogCategory.business,
    String? source,
    Map<String, Object?>? data,
  }) =>
      _dispatcher.log(TailsLogLevel.info, message, category: category, source: source, data: data);

  /// Подозрительная ситуация, которая не ломает сценарий.
  static void warning(
    String message, {
    TailsLogCategory category = TailsLogCategory.business,
    String? source,
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
  }) => _dispatcher.log(
    TailsLogLevel.warning,
    message,
    category: category,
    source: source,
    data: data,
    error: error,
    stackTrace: stackTrace,
  );

  /// Ошибка операции.
  ///
  /// [report] = `false` исключает запись из отправки во внешний сервис: так делают слои,
  /// которые не владеют ошибкой, чтобы она не была отправлена дважды.
  static void error(
    String message, {
    TailsLogCategory category = TailsLogCategory.business,
    String? source,
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
    bool report = true,
  }) => _dispatcher.log(
    TailsLogLevel.error,
    message,
    category: category,
    source: source,
    data: data,
    error: error,
    stackTrace: stackTrace,
    report: report,
  );

  /// Критическая ошибка приложения.
  static void fatal(
    String message, {
    TailsLogCategory category = TailsLogCategory.business,
    String? source,
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
    bool report = true,
  }) => _dispatcher.log(
    TailsLogLevel.fatal,
    message,
    category: category,
    source: source,
    data: data,
    error: error,
    stackTrace: stackTrace,
    report: report,
  );
}

/// Создаёт записи и раздаёт их получателям.
final class TailsLogDispatcher {
  /// Создаёт диспетчер с заданными получателями.
  TailsLogDispatcher({List<TailsLogSink> sinks = const []}) : _sinks = List.unmodifiable(sinks);

  final List<TailsLogSink> _sinks;

  var _sequence = 0;
  var _isDispatching = false;

  /// Нужна ли кому-то из получателей запись с таким [level] и [category].
  bool isEnabled(TailsLogLevel level, TailsLogCategory category) =>
      _sinks.any((sink) => sink.isEnabled(level, category));

  /// Создаёт запись и передаёт её получателям, которым она нужна.
  ///
  /// Сбой одного получателя не мешает остальным и не ломает приложение. Вызов журнала
  /// из получателя во время записи игнорируется, чтобы не получить рекурсию.
  void log(
    TailsLogLevel level,
    String message, {
    required TailsLogCategory category,
    String? source,
    Map<String, Object?>? data,
    Object? error,
    StackTrace? stackTrace,
    bool report = true,
  }) {
    if (_isDispatching) return;

    final targets = _sinks.where((sink) => sink.isEnabled(level, category)).toList();
    if (targets.isEmpty) return;

    final event = TailsLogEvent(
      sequence: ++_sequence,
      time: clock.now(),
      level: level,
      category: category,
      message: message,
      source: source,
      data: data == null ? const {} : Map.unmodifiable(data),
      error: error,
      stackTrace: stackTrace,
      report: report,
    );

    _isDispatching = true;
    try {
      for (final sink in targets) {
        try {
          sink.write(event);
        } on Object catch (sinkError, sinkStackTrace) {
          developer.log(
            'Получатель журнала ${sink.runtimeType} завершился ошибкой',
            name: 'TailsLogger',
            error: sinkError,
            stackTrace: sinkStackTrace,
          );
        }
      }
    } finally {
      _isDispatching = false;
    }
  }
}
