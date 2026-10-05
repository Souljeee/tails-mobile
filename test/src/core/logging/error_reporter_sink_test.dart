import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/sinks/error_reporter_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/error_reporter.dart';

void main() {
  late _FakeErrorReporter reporter;
  late ErrorReporterSink sink;

  TailsLogEvent event({
    TailsLogLevel level = TailsLogLevel.error,
    Object? error,
    StackTrace? stackTrace,
    String message = 'Что-то пошло не так',
    bool report = true,
  }) => TailsLogEvent(
    sequence: 1,
    time: DateTime(2026, 10, 5),
    level: level,
    category: TailsLogCategory.app,
    message: message,
    error: error,
    stackTrace: stackTrace,
    report: report,
  );

  setUp(() {
    reporter = _FakeErrorReporter();
    sink = ErrorReporterSink(reporter: reporter, config: const TailsLogConfig.debug());
  });

  tearDown(TailsLogger.reset);

  group('ErrorReporterSink', () {
    test('принимает только error и fatal', () {
      expect(sink.isEnabled(TailsLogLevel.warning, TailsLogCategory.app), isFalse);
      expect(sink.isEnabled(TailsLogLevel.error, TailsLogCategory.app), isTrue);
      expect(sink.isEnabled(TailsLogLevel.fatal, TailsLogCategory.app), isTrue);
    });

    test('не принимает записи, пока сервис не инициализирован', () {
      reporter.initialized = false;

      expect(sink.isEnabled(TailsLogLevel.fatal, TailsLogCategory.app), isFalse);
    });

    test('отправляет ошибку со стеком', () async {
      final error = StateError('boom');
      final stack = StackTrace.fromString('#0 main (file.dart:1)');

      sink.write(event(error: error, stackTrace: stack));
      await pumpEventQueue();

      expect(reporter.captured, hasLength(1));
      expect(reporter.captured.single.$1, same(error));
      expect(reporter.captured.single.$2, same(stack));
    });

    test('без ошибки отправляет сообщение как ReportedMessageException', () async {
      sink.write(event(message: 'Ничего не получилось'));
      await pumpEventQueue();

      expect(reporter.captured.single.$1, const ReportedMessageException('Ничего не получилось'));
      expect(reporter.captured.single.$2, isNotNull);
    });

    test('уважает report: false', () async {
      sink.write(event(error: StateError('network'), report: false));
      await pumpEventQueue();

      expect(reporter.captured, isEmpty);
    });

    test('одну и ту же ошибку отправляет один раз', () async {
      final error = StateError('boom');
      final stack = StackTrace.fromString('#0 main (file.dart:1)');

      sink.write(event(error: error, stackTrace: stack));
      sink.write(event(error: error, stackTrace: stack, level: TailsLogLevel.fatal));
      await pumpEventQueue();

      expect(reporter.captured, hasLength(1));
    });

    test('сбой сервиса не пробрасывается наружу', () async {
      reporter.fail = true;

      expect(() => sink.write(event(error: StateError('boom'))), returnsNormally);
      await pumpEventQueue();
    });

    test('через TailsLogger: error в одном слое и fatal в другом дают один отчёт', () async {
      TailsLogger.configure(sinks: [sink]);
      final error = StateError('boom');
      final stack = StackTrace.fromString('#0 main (file.dart:1)');

      TailsLogger.error(
        'Ошибка',
        category: TailsLogCategory.bloc,
        source: 'PetBloc',
        error: error,
        stackTrace: stack,
      );
      TailsLogger.fatal(
        'Необработанная асинхронная ошибка',
        category: TailsLogCategory.app,
        source: 'Zone',
        error: error,
        stackTrace: stack,
      );
      await pumpEventQueue();

      expect(reporter.captured, hasLength(1));
    });
  });

  group('ErrorReportDeduplicator', () {
    test('повтором считает тот же объект ошибки', () {
      final deduplicator = ErrorReportDeduplicator();
      final error = StateError('boom');

      expect(deduplicator.isDuplicate(error: error), isFalse);
      expect(deduplicator.isDuplicate(error: error), isTrue);
    });

    test('повтором считает тот же текст стека у разных объектов ошибки', () {
      final deduplicator = ErrorReportDeduplicator();
      final stack = StackTrace.fromString('#0 main (file.dart:1)');

      expect(deduplicator.isDuplicate(error: StateError('a'), stackTrace: stack), isFalse);
      expect(
        deduplicator.isDuplicate(
          error: Exception('обёртка'),
          stackTrace: StackTrace.fromString('#0 main (file.dart:1)'),
        ),
        isTrue,
      );
    });

    test('разные ошибки не считаются повторами', () {
      final deduplicator = ErrorReportDeduplicator();

      expect(
        deduplicator.isDuplicate(
          error: StateError('a'),
          stackTrace: StackTrace.fromString('#0 a (a.dart:1)'),
        ),
        isFalse,
      );
      expect(
        deduplicator.isDuplicate(
          error: StateError('b'),
          stackTrace: StackTrace.fromString('#0 b (b.dart:1)'),
        ),
        isFalse,
      );
    });

    test('одинаковые строки без стека не считаются повторами', () {
      final deduplicator = ErrorReportDeduplicator();

      expect(deduplicator.isDuplicate(error: 'ошибка'), isFalse);
      expect(deduplicator.isDuplicate(error: 'ошибка'), isFalse);
    });

    test('записи без ошибки и стека не проверяются', () {
      final deduplicator = ErrorReportDeduplicator();

      expect(deduplicator.isDuplicate(), isFalse);
      expect(deduplicator.isDuplicate(), isFalse);
    });

    test('через окно ошибка снова считается новой', () {
      final deduplicator = ErrorReportDeduplicator();
      final error = StateError('boom');
      final start = DateTime(2026, 10, 5, 12);

      withClock(Clock.fixed(start), () => deduplicator.isDuplicate(error: error));

      final inside = withClock(
        Clock.fixed(start.add(const Duration(seconds: 4))),
        () => deduplicator.isDuplicate(error: error),
      );
      final outside = withClock(
        Clock.fixed(start.add(const Duration(seconds: 10))),
        () => deduplicator.isDuplicate(error: error),
      );

      expect(inside, isTrue);
      expect(outside, isFalse);
    });

    test('помнит не больше capacity ошибок', () {
      final deduplicator = ErrorReportDeduplicator(capacity: 2);
      final first = StateError('1');

      deduplicator.isDuplicate(error: first);
      deduplicator.isDuplicate(error: StateError('2'));
      deduplicator.isDuplicate(error: StateError('3'));

      expect(deduplicator.isDuplicate(error: first), isFalse);
    });
  });
}

final class _FakeErrorReporter implements ErrorReporter {
  bool initialized = true;
  bool fail = false;
  final List<(Object, StackTrace?)> captured = [];

  @override
  bool get isInitialized => initialized;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> captureException({required Object throwable, StackTrace? stackTrace}) async {
    if (fail) throw StateError('сервис недоступен');
    captured.add((throwable, stackTrace));
  }
}
