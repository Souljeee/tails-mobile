import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

import '../../../helpers/recording_log_sink.dart';

void main() {
  late RecordingLogSink sink;

  setUp(() {
    sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
    addTearDown(TailsLogger.reset);
  });

  group('TailsLogger', () {
    test('без получателей ничего не делает', () {
      TailsLogger.reset();

      expect(() => TailsLogger.info('сообщение'), returnsNormally);
      expect(TailsLogger.isEnabled(TailsLogLevel.fatal, TailsLogCategory.app), isFalse);
    });

    test('создаёт запись с категорией business по умолчанию', () {
      TailsLogger.info('Питомец открыт', data: {'petId': 3});

      final event = sink.events.single;
      expect(event.level, TailsLogLevel.info);
      expect(event.category, TailsLogCategory.business);
      expect(event.message, 'Питомец открыт');
      expect(event.data, {'petId': 3});
      expect(event.error, isNull);
      expect(event.report, isTrue);
    });

    test('каждый метод ставит свой уровень', () {
      TailsLogger.trace('t');
      TailsLogger.debug('d');
      TailsLogger.info('i');
      TailsLogger.warning('w');
      TailsLogger.error('e');
      TailsLogger.fatal('f');

      expect(sink.events.map((event) => event.level), TailsLogLevel.values);
    });

    test('передаёт категорию, компонент, ошибку и стек', () {
      final stackTrace = StackTrace.current;
      final error = StateError('сбой');

      TailsLogger.error(
        'Не удалось загрузить питомца',
        category: TailsLogCategory.network,
        source: 'PetRepository',
        error: error,
        stackTrace: stackTrace,
        report: false,
      );

      final event = sink.events.single;
      expect(event.category, TailsLogCategory.network);
      expect(event.source, 'PetRepository');
      expect(event.error, same(error));
      expect(event.stackTrace, same(stackTrace));
      expect(event.report, isFalse);
    });

    test('нумерует записи по порядку', () {
      TailsLogger.info('a');
      TailsLogger.info('b');
      TailsLogger.info('c');

      expect(sink.events.map((event) => event.sequence), [1, 2, 3]);
    });

    test('берёт время из clock', () {
      final fixed = DateTime(2026, 10, 5, 12, 3, 41, 535);

      withClock(Clock.fixed(fixed), () => TailsLogger.info('a'));

      expect(sink.events.single.time, fixed);
    });

    test('копирует data, поэтому последующие правки исходной карты не меняют запись', () {
      final data = <String, Object?>{'a': 1};

      TailsLogger.info('a', data: data);
      data['a'] = 2;

      expect(sink.events.single.data, {'a': 1});
    });

    test('учитывает порог получателя и не создаёт лишнюю запись', () {
      final strict = RecordingLogSink(minLevel: TailsLogLevel.warning);
      TailsLogger.configure(sinks: [sink, strict]);

      TailsLogger.info('i');
      TailsLogger.warning('w');

      expect(sink.events, hasLength(2));
      expect(strict.events.map((event) => event.message), ['w']);
      expect(TailsLogger.isEnabled(TailsLogLevel.trace, TailsLogCategory.app), isTrue);
    });

    test('номер не расходуется, когда запись никому не нужна', () {
      TailsLogger.configure(sinks: [RecordingLogSink(minLevel: TailsLogLevel.error)]);

      TailsLogger.info('пропущено');

      TailsLogger.configure(sinks: [sink]);
      TailsLogger.info('первая');
      expect(sink.events.single.sequence, 1);
    });

    test('сбой одного получателя не мешает остальным', () {
      TailsLogger.configure(sinks: [_ThrowingSink(), sink]);

      expect(() => TailsLogger.error('e'), returnsNormally);
      expect(sink.events, hasLength(1));
    });

    test('вызов журнала из получателя игнорируется, а не зацикливается', () {
      final reentrant = _ReentrantSink();
      TailsLogger.configure(sinks: [reentrant, sink]);

      TailsLogger.info('внешняя');

      expect(reentrant.writes, 1);
      expect(sink.events.map((event) => event.message), ['внешняя']);
    });

    test('reset отключает получателей', () {
      TailsLogger.reset();

      TailsLogger.info('после reset');

      expect(sink.events, isEmpty);
    });
  });

  group('TailsLogLevel', () {
    test('isAtLeast сравнивает по важности', () {
      expect(TailsLogLevel.error.isAtLeast(TailsLogLevel.warning), isTrue);
      expect(TailsLogLevel.warning.isAtLeast(TailsLogLevel.warning), isTrue);
      expect(TailsLogLevel.debug.isAtLeast(TailsLogLevel.info), isFalse);
    });
  });
}

final class _ThrowingSink implements TailsLogSink {
  @override
  bool isEnabled(TailsLogLevel level, TailsLogCategory category) => true;

  @override
  void write(TailsLogEvent event) => throw StateError('сбой получателя');
}

final class _ReentrantSink implements TailsLogSink {
  int writes = 0;

  @override
  bool isEnabled(TailsLogLevel level, TailsLogCategory category) => true;

  @override
  void write(TailsLogEvent event) {
    writes++;
    TailsLogger.info('изнутри получателя');
  }
}
