import 'dart:async';

import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_sanitizer.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

/// Единая точка отправки продуктовой аналитики.
///
/// Код приложения знает только об этом классе и каталоге `TailsAnalyticsEvents`;
/// в какие сервисы уходят события, решают подключённые [TailsAnalyticsSink].
/// Вызов до [configure] и любой сбой получателей безопасны и ничего не ломают.
///
/// ```dart
/// TailsAnalytics.log(TailsAnalyticsEvents.petCreated(...));
/// TailsAnalytics.setUser(userId);
/// ```
abstract final class TailsAnalytics {
  static TailsAnalyticsDispatcher _dispatcher = TailsAnalyticsDispatcher();

  /// Подключает получателей. Вызывается один раз при старте приложения.
  static void configure({
    required List<TailsAnalyticsSink> sinks,
    TailsAnalyticsSanitizer sanitizer = const TailsAnalyticsSanitizer(),
  }) {
    _dispatcher = TailsAnalyticsDispatcher(sinks: sinks, sanitizer: sanitizer);
  }

  /// Отключает получателей. Нужен тестам: `addTearDown(TailsAnalytics.reset)`.
  static void reset() {
    _dispatcher = TailsAnalyticsDispatcher();
  }

  /// Отправляет событие всем получателям, не дожидаясь результата.
  static void log(TailsAnalyticsEvent event) => _dispatcher.log(event);

  /// Привязывает события к пользователю (внутренний id, без телефона и имени).
  static void setUser(String userId) => _dispatcher.setUser(userId);

  /// Снимает привязку к пользователю (выход, удаление аккаунта).
  static void clearUser() => _dispatcher.setUser(null);

  /// Устанавливает свойство пользователя.
  static void setUserProperty(TailsAnalyticsUserProperty property, Object value) =>
      _dispatcher.setUserProperty(property, value);
}

/// Очищает события и раздаёт их получателям.
final class TailsAnalyticsDispatcher {
  /// Создаёт диспетчер с заданными получателями.
  TailsAnalyticsDispatcher({
    List<TailsAnalyticsSink> sinks = const [],
    TailsAnalyticsSanitizer sanitizer = const TailsAnalyticsSanitizer(),
  }) : _sinks = List.unmodifiable(sinks),
       _sanitizer = sanitizer;

  final List<TailsAnalyticsSink> _sinks;
  final TailsAnalyticsSanitizer _sanitizer;

  /// Минимальный интервал между предупреждениями об одном и том же сбое.
  static const _warningInterval = Duration(minutes: 1);
  final Map<String, DateTime> _lastWarning = {};

  /// Отправляет событие.
  void log(TailsAnalyticsEvent event) {
    if (_sinks.isEmpty) return;

    final clean = _sanitizer.sanitize(event);
    if (clean == null) {
      _warn('invalid_event', 'Событие аналитики отклонено: недопустимое имя', {
        'event': event.name,
      });

      return;
    }

    for (final sink in _sinks) {
      _run(sink, 'logEvent', () => sink.logEvent(clean));
    }
  }

  /// Привязывает пользователя; `null` снимает привязку.
  void setUser(String? userId) {
    if (_sinks.isEmpty) return;

    for (final sink in _sinks) {
      _run(sink, 'setUserId', () => sink.setUserId(userId));
    }
  }

  /// Устанавливает свойство пользователя.
  void setUserProperty(TailsAnalyticsUserProperty property, Object value) {
    if (_sinks.isEmpty) return;

    final clean = _sanitizer.sanitizeValue(value);
    if (clean == null) return;

    for (final sink in _sinks) {
      _run(sink, 'setUserProperty', () => sink.setUserProperty(property, clean));
    }
  }

  void _run(TailsAnalyticsSink sink, String operation, Future<void> Function() action) {
    unawaited(
      Future<void>.sync(action).catchError((Object error, StackTrace stackTrace) {
        _warn(
          '${sink.name}:$operation',
          'Сбой приёмника аналитики',
          {'sink': sink.name, 'operation': operation},
          error: error,
          stackTrace: stackTrace,
        );
      }),
    );
  }

  void _warn(
    String key,
    String message,
    Map<String, Object?> data, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final now = DateTime.now();
    final last = _lastWarning[key];
    if (last != null && now.difference(last) < _warningInterval) return;
    _lastWarning[key] = now;

    TailsLogger.warning(
      message,
      category: TailsLogCategory.app,
      source: 'TailsAnalytics',
      data: data,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
