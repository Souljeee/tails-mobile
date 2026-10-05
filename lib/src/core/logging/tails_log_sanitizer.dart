import 'package:meta/meta.dart';

/// Ошибка, у которой чувствительные фрагменты текста заменены на `[REDACTED]`.
///
/// Подставляется вместо исходного исключения только тогда, когда его текст
/// пришлось очистить; обычные исключения передаются получателям без изменений.
@immutable
final class TailsSanitizedException implements Exception {
  /// Создаёт очищенную копию ошибки.
  const TailsSanitizedException({required this.originalType, required this.message});

  /// Тип исходного исключения.
  final String originalType;

  /// Очищенный текст исходного исключения (результат его `toString()`).
  final String message;

  @override
  String toString() => message;
}

/// Убирает из записей журнала чувствительные данные.
///
/// Применяется один раз в диспетчере до передачи записи получателям, поэтому консоль,
/// файл и внешние сервисы получают уже очищенные данные. Работает по трём правилам:
///
/// * значения по чувствительным ключам (`token`, `password`, `Authorization`, `Cookie`,
///   SMS-код и т. п.) заменяются на `[REDACTED]`;
/// * телефоны маскируются (`+7***2233`) и по ключу (`phoneNumber`), и в тексте;
/// * в тексте вычищаются JWT, `Bearer`-токены и пары вида `password=...`.
///
/// Длинные строки и большие коллекции обрезаются, чтобы журнал не засорялся.
///
/// Свободный текст очищается только по шаблонам: надёжно он не защищён, поэтому
/// переменные значения нужно передавать в `data`, а не в текст сообщения.
@immutable
final class TailsLogSanitizer {
  /// Создаёт санитайзер.
  ///
  /// [extraSensitiveKeys] дополняет стандартный список ключей (сравнение без учёта
  /// регистра и разделителей, по вхождению).
  const TailsLogSanitizer({
    this.extraSensitiveKeys = const {},
    this.maxStringLength = 2000,
    this.maxDepth = 6,
    this.maxCollectionItems = 100,
  });

  /// Значение, которым заменяются секреты.
  static const redacted = '[REDACTED]';

  /// Дополнительные чувствительные ключи.
  final Set<String> extraSensitiveKeys;

  /// Максимальная длина строки; остальное обрезается.
  final int maxStringLength;

  /// Максимальная вложенность карт и списков.
  final int maxDepth;

  /// Максимальное число элементов коллекции.
  final int maxCollectionItems;

  /// Ключи, которые чувствительны, если содержат фрагмент (нормализованный).
  static const _sensitiveParts = [
    'authorization',
    'cookie',
    'password',
    'passwd',
    'passcode',
    'token',
    'secret',
    'apikey',
    'credential',
    'smscode',
    'confirmationcode',
    'verificationcode',
    'authcode',
  ];

  /// Ключи, которые чувствительны только при полном совпадении (нормализованном).
  static const _sensitiveExact = {'code', 'access', 'refresh', 'otp', 'pin', 'cvv', 'cvc'};

  static const _phoneParts = ['phone', 'msisdn'];

  static final _keySeparators = RegExp(r'[\s_\-.]');

  static final _jwt = RegExp(r'\beyJ[A-Za-z0-9_-]{5,}\.[A-Za-z0-9_-]{5,}\.[A-Za-z0-9_-]*');

  static final _authScheme = RegExp(
    r'\b(Bearer|Basic)\s+[A-Za-z0-9\-._~+/]+=*',
    caseSensitive: false,
  );

  static final _secretPair = RegExp(
    r'''(["']?(?:access[_-]?token|refresh[_-]?token|id[_-]?token|token|password|passwd|secret|api[_-]?key|authorization)["']?\s*[:=]\s*)("[^"]*"|'[^']*'|(?:Bearer|Basic)\s+[^\s,;&}\]]+|[^\s,;&}\]]+)''',
    caseSensitive: false,
  );

  static final _russianPhone = RegExp(
    r'(?<![\w+])(?:\+7|[78])[\s\-(]*\d{3}[\s\-)]*\d{3}[\s\-]*\d{2}[\s\-]*\d{2}(?!\d)',
  );

  static final _internationalPhone = RegExp(r'(?<!\w)\+\d[\d\-\s()]{8,16}\d(?!\d)');

  /// Очищает значение [value], лежащее под ключом [key].
  ///
  /// Для карт и списков обходит содержимое рекурсивно.
  Object? sanitizeValue(Object? value, {String? key}) => _sanitize(value, key, 0);

  /// Очищает структурированные поля записи.
  Map<String, Object?> sanitizeData(Map<String, Object?> data) {
    return {for (final entry in data.entries) entry.key: _sanitize(entry.value, entry.key, 1)};
  }

  /// Очищает заголовки: значения чувствительных заголовков заменяются на `[REDACTED]`.
  Map<String, String> sanitizeHeaders(Map<String, String> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: isSensitiveKey(entry.key) ? redacted : sanitizeText(entry.value),
    };
  }

  /// Очищает текст по шаблонам и обрезает его до [maxStringLength].
  String sanitizeText(String text) => _truncate(_scrub(text));

  /// Возвращает [error] без изменений, если его текст чистый, иначе очищенную копию.
  Object? sanitizeError(Object? error) {
    if (error == null) return null;

    final text = '$error';
    final scrubbed = _scrub(text);
    if (scrubbed == text) return error;

    return TailsSanitizedException(originalType: '${error.runtimeType}', message: scrubbed);
  }

  /// Чувствительный ли ключ: значение под ним заменяется на `[REDACTED]`.
  bool isSensitiveKey(String key) {
    final normalized = _normalize(key);

    if (_sensitiveExact.contains(normalized)) return true;
    if (_sensitiveParts.any(normalized.contains)) return true;

    return extraSensitiveKeys.any((extra) => normalized.contains(_normalize(extra)));
  }

  /// Маскирует телефон, оставляя код страны и последние четыре цифры: `+7***2233`.
  ///
  /// Повторный вызов безопасен: уже замаскированное значение возвращается как есть.
  static String maskPhone(String value) {
    if (value.contains('***')) return value;

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return '***';

    final tail = digits.substring(digits.length - 4);

    return digits.length >= 11 ? '+${digits[0]}***$tail' : '***$tail';
  }

  Object? _sanitize(Object? value, String? key, int depth) {
    if (value == null) return null;
    if (key != null && isSensitiveKey(key)) return redacted;
    if (key != null && _isPhoneKey(key) && (value is String || value is num)) {
      return maskPhone('$value');
    }
    if (depth > maxDepth) return '[слишком глубоко]';

    switch (value) {
      case final String text:
        return sanitizeText(text);
      case num() || bool():
        return value;
      case final DateTime time:
        return time.toIso8601String();
      case final Map<Object?, Object?> map:
        return _sanitizeMap(map, depth);
      case final Iterable<Object?> items:
        return _sanitizeIterable(items, key, depth);
      default:
        return sanitizeText('$value');
    }
  }

  Map<String, Object?> _sanitizeMap(Map<Object?, Object?> map, int depth) {
    final result = <String, Object?>{};
    for (final entry in map.entries.take(maxCollectionItems)) {
      final name = '${entry.key}';
      result[name] = _sanitize(entry.value, name, depth + 1);
    }
    final hidden = map.length - maxCollectionItems;
    if (hidden > 0) result['…'] = 'ещё $hidden';

    return result;
  }

  List<Object?> _sanitizeIterable(Iterable<Object?> items, String? key, int depth) {
    final result = <Object?>[];
    var count = 0;
    for (final item in items) {
      if (count >= maxCollectionItems) {
        count++;
        continue;
      }
      result.add(_sanitize(item, key, depth + 1));
      count++;
    }
    final hidden = count - maxCollectionItems;
    if (hidden > 0) result.add('… ещё $hidden');

    return result;
  }

  bool _isPhoneKey(String key) {
    final normalized = _normalize(key);

    return _phoneParts.any(normalized.contains);
  }

  String _normalize(String key) => key.toLowerCase().replaceAll(_keySeparators, '');

  String _scrub(String text) {
    return text
        .replaceAll(_jwt, redacted)
        .replaceAllMapped(_secretPair, (match) => '${match[1]}$redacted')
        .replaceAllMapped(_authScheme, (match) => '${match[1]} $redacted')
        .replaceAllMapped(_russianPhone, (match) => maskPhone(match[0]!))
        .replaceAllMapped(_internationalPhone, (match) => maskPhone(match[0]!));
  }

  String _truncate(String text) {
    if (text.length <= maxStringLength) return text;

    return '${text.substring(0, maxStringLength)}…[обрезано ${text.length - maxStringLength} симв.]';
  }
}
