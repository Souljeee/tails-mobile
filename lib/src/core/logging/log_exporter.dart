import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:tails_mobile/src/core/logging/sinks/file_log_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sanitizer.dart';

/// Собирает сохранённый журнал в один gzip-файл для отправки вместе с обращением.
///
/// Перед упаковкой каждая строка ещё раз проходит через [TailsLogSanitizer]: записи уже
/// очищены при создании, но это второй рубеж на случай, если правила очистки пополнились
/// после того, как запись была сделана. Если журнал не помещается в [maxCompressedBytes],
/// отбрасываются самые старые записи: для разбора обращения важнее последние.
final class LogExporter {
  /// Создаёт экспортёр журнала, который хранит [sink].
  const LogExporter({
    required FileLogSink sink,
    TailsLogSanitizer sanitizer = const TailsLogSanitizer(maxStringLength: 4000),
    this.maxCompressedBytes = 2 * 1024 * 1024 - 64 * 1024,
  }) : _sink = sink,
       _sanitizer = sanitizer;

  /// Максимальный размер gzip-файла. Сервер принимает до 2 МБ; запас берётся на заголовки.
  final int maxCompressedBytes;

  final FileLogSink _sink;
  final TailsLogSanitizer _sanitizer;

  /// Возвращает gzip-архив журнала или `null`, если журнал пуст или недоступен.
  Future<Uint8List?> export() async {
    try {
      final files = await _sink.files();
      final lines = <String>[];

      for (final file in files) {
        final text = utf8.decode(await file.readAsBytes(), allowMalformed: true);
        lines.addAll(const LineSplitter().convert(text).map(_sanitizer.sanitizeText));
      }

      if (lines.isEmpty) return null;

      return _pack(lines);
    } on Object {
      // Сбой чтения журнала не должен мешать отправке обращения.
      return null;
    }
  }

  Uint8List _pack(List<String> lines) {
    var start = 0;

    while (true) {
      final packed = Uint8List.fromList(
        gzip.encode(utf8.encode('${lines.skip(start).join('\n')}\n')),
      );

      if (packed.length <= maxCompressedBytes || start >= lines.length - 1) return packed;

      // Отбрасываем старую половину оставшихся строк и пробуем снова.
      start += ((lines.length - start) / 2).ceil();
    }
  }
}
