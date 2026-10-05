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
  const TailsLogFormatter({this.includeDate = false, this.maxStackTraceLines = 25});

  /// Добавлять ли дату перед временем.
  final bool includeDate;

  /// Сколько строк стека выводить.
  final int maxStackTraceLines;

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

    for (final MapEntry(:key, :value) in event.data.entries) {
      header.write(' $key=${_formatValue(value)}');
    }

    final lines = <String>[header.toString()];

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
