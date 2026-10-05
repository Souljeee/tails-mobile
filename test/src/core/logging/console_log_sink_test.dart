import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/sinks/console_log_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

void main() {
  late List<String> lines;

  ConsoleLogSink sink(TailsLogConfig config) =>
      ConsoleLogSink(config: config, writeLine: lines.add);

  setUp(() {
    lines = [];
    addTearDown(TailsLogger.reset);
  });

  group('ConsoleLogSink', () {
    test('печатает запись одной строкой в формате журнала', () {
      TailsLogger.configure(sinks: [sink(const TailsLogConfig.debug())]);

      TailsLogger.info('→ #42 GET /pets/3/', category: TailsLogCategory.network);

      expect(lines, hasLength(1));
      expect(lines.single, matches(RegExp(r'^\d\d:\d\d:\d\d\.\d{3} I NET  → #42 GET /pets/3/$')));
    });

    test('печатает ошибку и стек отдельными строками', () {
      TailsLogger.configure(sinks: [sink(const TailsLogConfig.debug())]);

      TailsLogger.error('Сбой', error: StateError('x'), stackTrace: StackTrace.current);

      expect(lines.first, contains(' E BIZ  Сбой'));
      expect(lines[1], '    ↳ Bad state: x');
      expect(lines.length, greaterThan(2));
    });

    test('debug-конфигурация пропускает trace', () {
      TailsLogger.configure(sinks: [sink(const TailsLogConfig.debug())]);

      TailsLogger.trace('подробность');

      expect(lines, hasLength(1));
    });

    test('profile-конфигурация не печатает trace, но печатает debug', () {
      TailsLogger.configure(sinks: [sink(const TailsLogConfig.profile())]);

      TailsLogger.trace('подробность');
      TailsLogger.debug('отладка');

      expect(lines, hasLength(1));
      expect(lines.single, contains('отладка'));
    });

    test('release-конфигурация печатает warning и выше, а также сеть с уровня info', () {
      TailsLogger.configure(sinks: [sink(const TailsLogConfig.release())]);

      TailsLogger.info('обычное событие');
      TailsLogger.debug('запрос', category: TailsLogCategory.network);
      TailsLogger.info('→ #1 GET /pets/', category: TailsLogCategory.network);
      TailsLogger.warning('подозрительно');
      TailsLogger.error('ошибка');

      expect(lines, hasLength(3));
      expect(lines[0], contains('→ #1 GET /pets/'));
      expect(lines[1], contains('подозрительно'));
      expect(lines[2], contains('ошибка'));
    });

    test('isEnabled учитывает порог категории', () {
      final release = sink(const TailsLogConfig.release());

      expect(release.isEnabled(TailsLogLevel.info, TailsLogCategory.network), isTrue);
      expect(release.isEnabled(TailsLogLevel.info, TailsLogCategory.bloc), isFalse);
      expect(release.isEnabled(TailsLogLevel.warning, TailsLogCategory.bloc), isTrue);
    });

    test('пользовательские пороги из конфигурации применяются', () {
      TailsLogger.configure(
        sinks: [
          sink(
            const TailsLogConfig(
              consoleMinLevel: TailsLogLevel.error,
              consoleCategoryMinLevels: {TailsLogCategory.navigation: TailsLogLevel.debug},
            ),
          ),
        ],
      );

      TailsLogger.debug('переход', category: TailsLogCategory.navigation);
      TailsLogger.warning('мелочь');
      TailsLogger.error('сбой');

      expect(lines, hasLength(2));
    });
  });
}
