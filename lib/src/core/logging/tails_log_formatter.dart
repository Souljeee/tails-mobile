import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';

/// Превращает [TailsLogEvent] в строки журнала.
///
/// Главная строка читается слева направо: время, уровень, категория, компонент,
/// сообщение и поля `ключ=значение`. Исключение и стек идут отдельными строками
/// с отступом.
///
/// ```text
/// 12:03:41.535 I NET  → #42 GET /pets/3/ screen=pet-details
/// 12:03:41.719 E BLOC PetDetailsBloc#a3 error
///     ↳ ClientException(Connection timed out)
///     #0 PetRepository.getPetDetails (...)
/// ```
@immutable
final class TailsLogFormatter {
  /// Создаёт форматтер.
  ///
  /// [includeDate] добавляет дату к времени (нужно для файлов), а [maxStackTraceLines]
  /// ограничивает число строк стека.
  const TailsLogFormatter({
    this.includeDate = false,
    this.maxStackTraceLines = 25,
    this.pretty = false,
    this.hiddenDataKeys = const {},
  });

  /// Формат для консоли разработчика: данные записи выводятся блоками под главной строкой,
  /// тела обрезаются до короткого просмотра, заголовки скрыты (они есть в файле журнала).
  const TailsLogFormatter.console({int maxStackTraceLines = 25})
    : this(maxStackTraceLines: maxStackTraceLines, pretty: true, hiddenDataKeys: const {'headers'});

  /// Добавлять ли дату перед временем.
  final bool includeDate;

  /// Сколько строк стека выводить.
  final int maxStackTraceLines;

  /// Выводить данные записи читаемыми блоками под главной строкой.
  ///
  /// Короткие значения остаются в главной строке, а сетевые записи всегда выводятся блоками:
  /// метаданные одной строкой, тела и параметры — компактным просмотром.
  final bool pretty;

  /// Ключи данных, которые не выводятся (только вместе с [pretty]).
  final Set<String> hiddenDataKeys;

  static const _blockPrefix = '    │ ';
  static const _maxBlockLines = 24;
  static const _inlineLimit = 48;
  static const _previewDepth = 3;
  static const _previewItems = 2;
  static const _previewKeys = 6;
  static const _scalarMetaLimit = 40;
  static const _previewTextLength = 80;
  static const _plainTextLength = 200;

  static const _continuationIndent = '    ';

  /// Возвращает строки записи: главную и, при необходимости, строки с ошибкой и стеком.
  List<String> format(TailsLogEvent event) {
    final header = StringBuffer()
      ..write(_formatTime(event.time))
      ..write(' ${event.level.shortName} ')
      ..write(event.category.label.padRight(4))
      ..write(' ');

    if (event.source case final source? when source.isNotEmpty) {
      header.write('$source  ');
    }

    header.write(event.message);

    final blocks = <String>[];

    if (pretty) {
      _writePretty(event, header, blocks);
    } else {
      for (final MapEntry(:key, :value) in event.data.entries) {
        header.write(' $key=${_formatValue(value)}');
      }
    }

    final lines = <String>[header.toString(), ...blocks];

    if (event.error != null) {
      final errorLines = '${event.error}'.split('\n');
      lines.add('$_continuationIndent↳ ${errorLines.first}');
      for (final line in errorLines.skip(1)) {
        lines.add('$_continuationIndent  $line');
      }
    }

    if (event.stackTrace case final stackTrace? when '$stackTrace'.trim().isNotEmpty) {
      final stackLines = '$stackTrace'.trim().split('\n');
      for (final line in stackLines.take(maxStackTraceLines)) {
        lines.add('$_continuationIndent$line');
      }
      final hidden = stackLines.length - maxStackTraceLines;
      if (hidden > 0) {
        lines.add('$_continuationIndent… ещё $hidden строк стека');
      }
    }

    return lines;
  }

  /// Раскладывает данные записи: короткое — в главную строку, остальное — блоками.
  void _writePretty(TailsLogEvent event, StringBuffer header, List<String> blocks) {
    final isNetwork = event.category == TailsLogCategory.network;
    final scalars = <String>[];
    final details = <MapEntry<String, Object?>>[];

    for (final entry in event.data.entries) {
      if (hiddenDataKeys.contains(entry.key)) continue;

      final value = entry.value;
      final formatted = _isScalar(value) ? _formatValue(value) : null;

      if (isNetwork) {
        // Короткие скалярные поля (экран, BLoC, id) идут одной строкой, тела — отдельно.
        if (formatted != null && formatted.length <= _scalarMetaLimit) {
          scalars.add('${entry.key}=$formatted');
        } else {
          details.add(entry);
        }
      } else {
        final inline = formatted ?? _formatValue(value);
        if (inline.length <= _inlineLimit && !inline.contains('\n')) {
          header.write(' ${entry.key}=$inline');
        } else {
          details.add(entry);
        }
      }
    }

    if (scalars.isNotEmpty) blocks.add('$_blockPrefix${scalars.join('  ')}');
    for (final entry in details) {
      blocks.addAll(_detailLines(entry.key, entry.value));
    }
  }

  List<String> _detailLines(String key, Object? value) {
    if (value is String) {
      return ['$_blockPrefix$key: ${_plainText(value)}'];
    }

    if (value is Map<Object?, Object?> && _isFlat(value) && value.isNotEmpty) {
      final text = value.entries.map((e) => '${e.key}=${_formatValue(e.value)}').join('  ');
      if (text.length <= 120) return ['$_blockPrefix$key: $text'];
    }

    final preview = _prettyJson(_reduce(value, 0));
    final lines = preview.split('\n');
    final shown = lines.take(_maxBlockLines).toList();
    final result = <String>['$_blockPrefix$key: ${shown.first}'];
    for (final line in shown.skip(1)) {
      result.add('$_blockPrefix$line');
    }
    if (lines.length > shown.length) {
      result.add('$_blockPrefix… ещё ${lines.length - shown.length} строк');
    }

    return result;
  }

  /// Сворачивает пробелы и обрезает: так HTML-страница ошибки занимает одну строку.
  String _plainText(String text) {
    // У HTML-страницы (например, 404 от сервера) важен только заголовок.
    final trimmed = text.trimLeft().toLowerCase();
    if (trimmed.startsWith('<!doctype') || trimmed.startsWith('<html')) {
      final title = RegExp('<title[^>]*>(.*?)</title>', dotAll: true).firstMatch(text)?.group(1);
      final summary = title == null ? 'страница без заголовка' : title.trim();

      return '[HTML] $summary (${text.length} симв.)';
    }

    final collapsed = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.length <= _plainTextLength) return collapsed;

    return '${collapsed.substring(0, _plainTextLength)}… (ещё ${collapsed.length - _plainTextLength} симв.)';
  }

  /// Сокращает структуру для просмотра: ограничивает вложенность, число элементов
  /// и длину строк.
  Object? _reduce(Object? value, int depth) {
    switch (value) {
      case final Map<Object?, Object?> map:
        if (depth >= _previewDepth) return '{…${map.length}}';
        final entries = map.entries.toList();
        final reduced = <String, Object?>{
          for (final entry in entries.take(_previewKeys))
            '${entry.key}': _reduce(entry.value, depth + 1),
        };
        if (entries.length > _previewKeys) {
          reduced['…'] = '+${entries.length - _previewKeys}';
        }

        return reduced;
      case final Iterable<Object?> list:
        final items = list.toList();
        if (depth >= _previewDepth) return '[…${items.length}]';
        final reduced = <Object?>[
          for (final item in items.take(_previewItems)) _reduce(item, depth + 1),
        ];
        if (items.length > _previewItems) reduced.add('… +${items.length - _previewItems}');

        return reduced;
      case final String text when text.length > _previewTextLength:
        return '${text.substring(0, _previewTextLength)}…';
      default:
        return value;
    }
  }

  String _prettyJson(Object? value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } on Object {
      return '$value';
    }
  }

  static bool _isScalar(Object? value) =>
      value == null || value is String || value is num || value is bool;

  static bool _isFlat(Map<Object?, Object?> map) => map.values.every(_isScalar);

  String _formatTime(DateTime time) {
    String pad(int value, [int width = 2]) => value.toString().padLeft(width, '0');

    final clockPart =
        '${pad(time.hour)}:${pad(time.minute)}:${pad(time.second)}.${pad(time.millisecond, 3)}';
    if (!includeDate) return clockPart;

    return '${pad(time.year, 4)}-${pad(time.month)}-${pad(time.day)} $clockPart';
  }

  String _formatValue(Object? value) {
    switch (value) {
      case null:
        return 'null';
      case final String text:
        final needsQuotes = text.isEmpty || text.contains(RegExp(r'[\s"=]'));

        return needsQuotes ? jsonEncode(text) : text;
      case final num number:
        return '$number';
      case final bool flag:
        return '$flag';
      case final Iterable<Object?> _ || final Map<Object?, Object?> _:
        try {
          return jsonEncode(value, toEncodable: (object) => '$object');
        } on Object {
          return '$value';
        }
      default:
        return '$value';
    }
  }
}
