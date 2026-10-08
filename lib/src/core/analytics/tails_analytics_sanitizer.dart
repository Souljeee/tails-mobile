import 'package:tails_mobile/src/core/analytics/tails_analytics_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sanitizer.dart';

/// Проверяет и очищает события перед отправкой во внешние сервисы.
///
/// Аналитика не должна содержать персональных данных: запрещённые имена параметров
/// удаляются, строки очищаются по шаблонам и обрезаются, типы ограничены.
final class TailsAnalyticsSanitizer {
  /// Создаёт санитайзер.
  const TailsAnalyticsSanitizer({this.textSanitizer = const TailsLogSanitizer()});

  /// Очистка свободного текста (телефоны, токены и т. п.).
  final TailsLogSanitizer textSanitizer;

  /// Максимум параметров события (ограничение Firebase — 25, берём с запасом меньше).
  static const maxParameters = 10;

  /// Максимальная длина строкового значения.
  static const maxValueLength = 100;

  static final _eventName = RegExp(r'^[a-z][a-z0-9_]{0,39}$');

  static const _forbiddenKeys = {
    'phone',
    'phone_number',
    'name',
    'first_name',
    'last_name',
    'pet_name',
    'title',
    'description',
    'message',
    'email',
    'token',
    'code',
    'password',
    'address',
    'text',
    'comment',
  };

  static const _forbiddenFragments = ['token', 'password', 'phone'];

  /// Допустимо ли имя события.
  bool isValidName(String name) => _eventName.hasMatch(name);

  /// Допустимо ли имя параметра.
  bool isValidKey(String key) {
    if (!_eventName.hasMatch(key)) return false;
    if (_forbiddenKeys.contains(key)) return false;

    return !_forbiddenFragments.any(key.contains);
  }

  /// Возвращает очищенное событие или `null`, если имя события недопустимо.
  TailsAnalyticsEvent? sanitize(TailsAnalyticsEvent event) {
    if (!isValidName(event.name)) return null;

    final result = <String, Object>{};
    for (final entry in event.parameters.entries) {
      if (result.length >= maxParameters) break;
      if (!isValidKey(entry.key)) continue;

      final value = sanitizeValue(entry.value);
      if (value != null) result[entry.key] = value;
    }

    return TailsAnalyticsEvent(event.name, parameters: Map.unmodifiable(result));
  }

  /// Очищает одно значение; `null` — значение недопустимого типа.
  Object? sanitizeValue(Object? value) => switch (value) {
    final String text => _text(text),
    final int number => number,
    final double number when number.isFinite => number,
    final bool flag => flag,
    _ => null,
  };

  String _text(String text) {
    final clean = textSanitizer.sanitizeText(text);

    return clean.length <= maxValueLength ? clean : clean.substring(0, maxValueLength);
  }
}
