import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/log_exporter.dart';
import 'package:tails_mobile/src/core/logging/sinks/file_log_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

void main() {
  late Directory directory;
  late FileLogSink sink;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('log_exporter_test');
    sink = FileLogSink(
      directory: directory,
      config: const TailsLogConfig(consoleMinLevel: TailsLogLevel.trace),
    );
    TailsLogger.configure(sinks: [sink]);
  });

  tearDown(() {
    TailsLogger.reset();
    directory.deleteSync(recursive: true);
  });

  String unpack(List<int> bytes) => utf8.decode(gzip.decode(bytes));

  test('пустой журнал даёт null', () async {
    expect(await LogExporter(sink: sink).export(), isNull);
  });

  test('возвращает корректный gzip с записями в порядке создания', () async {
    TailsLogger.info('первая');
    TailsLogger.warning('вторая');

    final bytes = await LogExporter(sink: sink).export();

    expect(bytes, isNotNull);
    // Заголовок gzip.
    expect(bytes!.sublist(0, 2), [0x1f, 0x8b]);
    final text = unpack(bytes);
    expect(text, contains('первая'));
    expect(text.indexOf('первая'), lessThan(text.indexOf('вторая')));
  });

  test('включает буфер, ещё не записанный на диск', () async {
    TailsLogger.info('только в памяти');

    final bytes = await LogExporter(sink: sink).export();

    expect(unpack(bytes!), contains('только в памяти'));
  });

  test('читает оба файла: предыдущий и текущий', () async {
    final rotating = FileLogSink(
      directory: directory,
      config: const TailsLogConfig(consoleMinLevel: TailsLogLevel.trace),
      maxFileBytes: 300,
    );
    TailsLogger.configure(sinks: [rotating]);
    for (final name in ['A', 'B']) {
      TailsLogger.info('$name ${'x' * 200}');
      await rotating.flush();
    }

    final text = unpack((await LogExporter(sink: rotating).export())!);

    expect(text, contains('A xxx'));
    expect(text, contains('B xxx'));
  });

  test('повторно очищает строки от секретов', () async {
    // Запись попала в файл в обход санитайзера, например, из старой версии приложения.
    File('${directory.path}/${FileLogSink.currentFileName}').writeAsStringSync(
      '2026-10-05 12:00:00.000 I NET  вход password=hunter2 phone +79001112233\n',
    );

    final text = unpack((await LogExporter(sink: sink).export())!);

    expect(text, isNot(contains('hunter2')));
    expect(text, isNot(contains('79001112233')));
    expect(text, contains('+7***2233'));
  });

  test('при превышении лимита отбрасывает самые старые записи', () async {
    final random = List.generate(
      400,
      (i) => 'запись-$i ${List.generate(40, (j) => (i * 31 + j * 17) % 9973).join('-')}',
    );
    File(
      '${directory.path}/${FileLogSink.currentFileName}',
    ).writeAsStringSync('${random.join('\n')}\n');

    final bytes = await LogExporter(sink: sink, maxCompressedBytes: 3000).export();

    expect(bytes!.length, lessThanOrEqualTo(3000));
    final text = unpack(bytes);
    expect(text, contains('запись-399'));
    expect(text, isNot(contains('запись-0 ')));
  });

  test('всегда оставляет хотя бы одну запись', () async {
    File('${directory.path}/${FileLogSink.currentFileName}').writeAsStringSync('одна запись\n');

    final bytes = await LogExporter(sink: sink, maxCompressedBytes: 1).export();

    expect(unpack(bytes!), contains('одна запись'));
  });
}
