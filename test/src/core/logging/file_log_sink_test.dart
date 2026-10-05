import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/sinks/file_log_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

void main() {
  late Directory directory;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('file_log_sink_test');
  });

  tearDown(() {
    TailsLogger.reset();
    directory.deleteSync(recursive: true);
  });

  FileLogSink createSink({
    int maxFileBytes = 1024 * 1024,
    Duration flushInterval = const Duration(hours: 1),
    TailsLogConfig config = const TailsLogConfig(consoleMinLevel: TailsLogLevel.trace),
  }) {
    final sink = FileLogSink(
      directory: directory,
      config: config,
      maxFileBytes: maxFileBytes,
      flushInterval: flushInterval,
    );
    TailsLogger.configure(sinks: [sink]);

    return sink;
  }

  File fileNamed(String name) => File('${directory.path}/$name');

  test('записывает строки после flush', () async {
    final sink = createSink();

    TailsLogger.info('первая', source: 'Test');
    TailsLogger.warning('вторая', data: {'id': 1});
    await sink.flush();

    final text = fileNamed(FileLogSink.currentFileName).readAsStringSync();
    expect(text, contains('Test  первая'));
    expect(text, contains('вторая id=1'));
    expect(text.indexOf('первая'), lessThan(text.indexOf('вторая')));
  });

  test('в файле есть дата перед временем', () async {
    final sink = createSink();

    TailsLogger.info('с датой');
    await sink.flush();

    expect(
      fileNamed(FileLogSink.currentFileName).readAsStringSync(),
      matches(RegExp(r'^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}')),
    );
  });

  test('не пишет на диск до flush или таймера, если уровень ниже error', () async {
    createSink();

    TailsLogger.info('в памяти');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(fileNamed(FileLogSink.currentFileName).existsSync(), isFalse);
  });

  test('error и fatal сбрасываются на диск сразу', () async {
    final sink = createSink();

    TailsLogger.info('до');
    TailsLogger.error('упало', report: false);
    await sink.files();

    final text = fileNamed(FileLogSink.currentFileName).readAsStringSync();
    expect(text, contains('до'));
    expect(text, contains('упало'));
  });

  test('сбрасывает по таймеру', () async {
    createSink(flushInterval: const Duration(milliseconds: 20));

    TailsLogger.info('по таймеру');
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(fileNamed(FileLogSink.currentFileName).readAsStringSync(), contains('по таймеру'));
  });

  test('учитывает порог fileMinLevel', () async {
    final sink = createSink(
      config: const TailsLogConfig(
        consoleMinLevel: TailsLogLevel.trace,
        fileMinLevel: TailsLogLevel.warning,
      ),
    );

    TailsLogger.info('лишнее');
    TailsLogger.warning('нужное');
    await sink.flush();

    final text = fileNamed(FileLogSink.currentFileName).readAsStringSync();
    expect(text, isNot(contains('лишнее')));
    expect(text, contains('нужное'));
  });

  test('ротация: старый файл становится предыдущим, самый старый удаляется', () async {
    final sink = createSink(maxFileBytes: 300);

    for (final name in ['A', 'B', 'C']) {
      TailsLogger.info('$name ${'x' * 200}');
      await sink.flush();
    }

    final previous = fileNamed(FileLogSink.previousFileName).readAsStringSync();
    final current = fileNamed(FileLogSink.currentFileName).readAsStringSync();
    expect(previous, contains('B xxx'));
    expect(current, contains('C xxx'));
    expect('$previous$current', isNot(contains('A xxx')));
  });

  test('общий размер журнала ограничен', () async {
    final sink = createSink(maxFileBytes: 500);

    for (var i = 0; i < 100; i++) {
      TailsLogger.info('запись $i ${'y' * 50}');
      await sink.flush();
    }

    final total = directory.listSync().whereType<File>().fold<int>(
      0,
      (sum, file) => sum + file.lengthSync(),
    );
    expect(total, lessThan(1500));
    expect(directory.listSync(), hasLength(2));
  });

  test('продолжает дописывать в существующий файл после перезапуска', () async {
    var sink = createSink();
    TailsLogger.info('сессия 1');
    await sink.flush();

    sink = createSink();
    TailsLogger.info('сессия 2');
    await sink.flush();

    final text = fileNamed(FileLogSink.currentFileName).readAsStringSync();
    expect(text, contains('сессия 1'));
    expect(text, contains('сессия 2'));
  });

  test('files возвращает файлы от старого к новому и сбрасывает буфер', () async {
    final sink = createSink(maxFileBytes: 300);
    TailsLogger.info('A ${'x' * 200}');
    await sink.flush();
    TailsLogger.info('B ${'x' * 200}');
    await sink.flush();
    TailsLogger.info('в буфере');

    final files = await sink.files();

    expect(files.map((file) => file.uri.pathSegments.last), [
      FileLogSink.previousFileName,
      FileLogSink.currentFileName,
    ]);
    expect(files.last.readAsStringSync(), contains('в буфере'));
  });

  test('files без записей возвращает пустой список', () async {
    final sink = createSink();

    expect(await sink.files(), isEmpty);
  });

  test('clear удаляет файлы и несброшенные записи', () async {
    final sink = createSink(maxFileBytes: 300);
    for (final name in ['A', 'B']) {
      TailsLogger.info('$name ${'x' * 200}');
      await sink.flush();
    }
    TailsLogger.info('не сброшено');

    await sink.clear();

    expect(directory.listSync(), isEmpty);
    expect(await sink.files(), isEmpty);
  });

  test('после clear запись идёт в новый файл', () async {
    final sink = createSink();
    TailsLogger.info('старое');
    await sink.flush();

    await sink.clear();
    TailsLogger.info('новое');
    await sink.flush();

    final text = fileNamed(FileLogSink.currentFileName).readAsStringSync();
    expect(text, contains('новое'));
    expect(text, isNot(contains('старое')));
  });

  test('сбой файловой системы не бросает исключений', () async {
    final blocker = File('${directory.path}/blocked')..writeAsStringSync('файл вместо папки');
    final sink = FileLogSink(
      directory: Directory('${blocker.path}/logs'),
      config: const TailsLogConfig(consoleMinLevel: TailsLogLevel.trace),
    );
    TailsLogger.configure(sinks: [sink]);

    TailsLogger.error('не запишется', report: false);

    await expectLater(sink.flush(), completes);
  });
}
