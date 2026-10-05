import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_formatter.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sink.dart';

/// Пишет журнал в файлы приватной папки приложения, чтобы его можно было приложить
/// к обращению в поддержку.
///
/// Хранятся два файла: текущий [currentFileName] и предыдущий [previousFileName]. Когда
/// текущий достигает [maxFileBytes], он становится предыдущим, а старый предыдущий удаляется,
/// поэтому журнал занимает не больше `2 × maxFileBytes`. Записи копятся в памяти и сбрасываются
/// на диск раз в [flushInterval], сразу при `error` и `fatal` и по вызову [flush]
/// (например, когда приложение уходит в фон). Файлы переживают падение приложения.
///
/// Запись на диск выполняется по очереди и не бросает исключений: сбой файловой системы
/// не должен ломать приложение.
final class FileLogSink implements TailsLogSink {
  /// Создаёт sink, пишущий в [directory]. Папка создаётся при первой записи.
  FileLogSink({
    required Directory directory,
    required TailsLogConfig config,
    TailsLogFormatter formatter = const TailsLogFormatter(includeDate: true),
    this.maxFileBytes = 1024 * 1024,
    this.flushInterval = const Duration(seconds: 3),
  }) : _directory = directory,
       _config = config,
       _formatter = formatter;

  /// Имя текущего файла журнала.
  static const String currentFileName = 'tails_log.txt';

  /// Имя предыдущего файла журнала.
  static const String previousFileName = 'tails_log.1.txt';

  /// Размер, после которого файл ротируется.
  final int maxFileBytes;

  /// Как долго записи могут ждать в памяти до сброса на диск.
  final Duration flushInterval;

  final Directory _directory;
  final TailsLogConfig _config;
  final TailsLogFormatter _formatter;

  final StringBuffer _buffer = StringBuffer();
  Timer? _timer;
  Future<void> _queue = Future.value();
  int? _currentSize;

  File get _current => File('${_directory.path}/$currentFileName');

  File get _previous => File('${_directory.path}/$previousFileName');

  @override
  bool isEnabled(TailsLogLevel level, TailsLogCategory category) =>
      level.isAtLeast(_config.fileMinLevel);

  @override
  void write(TailsLogEvent event) {
    _buffer.writeln(_formatter.format(event).join('\n'));

    if (event.level.isAtLeast(TailsLogLevel.error)) {
      unawaited(flush());
    } else {
      _timer ??= Timer(flushInterval, () => unawaited(flush()));
    }
  }

  /// Сбрасывает накопленные записи на диск. Завершается, когда запись закончена.
  Future<void> flush() {
    _timer?.cancel();
    _timer = null;

    if (_buffer.isEmpty) return _queue;

    final text = _buffer.toString();
    _buffer.clear();

    return _enqueue(() => _append(text));
  }

  /// Возвращает существующие файлы журнала от старого к новому, предварительно сбросив
  /// накопленные записи на диск.
  Future<List<File>> files() async {
    await flush();

    final result = <File>[];
    await _enqueue(() async {
      if (_previous.existsSync()) result.add(_previous);
      if (_current.existsSync()) result.add(_current);
    });

    return result;
  }

  /// Удаляет весь сохранённый журнал и несброшенные записи.
  ///
  /// Вызывается при выходе из аккаунта и удалении аккаунта. Записи, сделанные после вызова,
  /// попадают уже в новый файл.
  Future<void> clear() {
    _timer?.cancel();
    _timer = null;
    _buffer.clear();

    return _enqueue(() async {
      _currentSize = null;
      for (final file in [_previous, _current]) {
        if (file.existsSync()) await file.delete();
      }
    });
  }

  Future<void> _enqueue(Future<void> Function() action) =>
      _queue = _queue.then((_) => action()).catchError((Object error, StackTrace stackTrace) {
        developer.log(
          'Не удалось записать журнал в файл',
          name: 'FileLogSink',
          error: error,
          stackTrace: stackTrace,
        );
      });

  Future<void> _append(String text) async {
    await _directory.create(recursive: true);

    final bytes = utf8.encode(text);
    final file = _current;
    var size = _currentSize ??= file.existsSync() ? await file.length() : 0;

    if (size > 0 && size + bytes.length > maxFileBytes) {
      if (_previous.existsSync()) await _previous.delete();
      await file.rename(_previous.path);
      size = 0;
    }

    await file.writeAsBytes(bytes, mode: FileMode.append, flush: true);
    _currentSize = size + bytes.length;
  }
}
