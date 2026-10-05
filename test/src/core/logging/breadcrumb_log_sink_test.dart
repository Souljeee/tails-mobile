import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/sinks/breadcrumb_log_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sanitizer.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/error_reporter.dart';

void main() {
  late _Reporter reporter;

  setUp(() {
    reporter = _Reporter();
    TailsLogger.configure(
      sinks: [
        BreadcrumbLogSink(
          reporter: reporter,
          config: const TailsLogConfig(consoleMinLevel: TailsLogLevel.debug),
        ),
      ],
    );
  });

  tearDown(TailsLogger.reset);

  test('передаёт записи от info и выше', () {
    TailsLogger.debug('мелочь');
    TailsLogger.info('шаг');
    TailsLogger.warning('странно');
    TailsLogger.error('ошибка', report: false);

    expect(reporter.breadcrumbs.map((b) => b.level), [
      BreadcrumbLevel.info,
      BreadcrumbLevel.warning,
      BreadcrumbLevel.error,
    ]);
  });

  test('добавляет источник к сообщению и категорию', () {
    TailsLogger.info('открыт', category: TailsLogCategory.navigation, source: 'Router');

    expect(reporter.breadcrumbs.single.message, 'Router: открыт');
    expect(reporter.breadcrumbs.single.category, 'navigation');
  });

  test('данные передаются, но не для сетевой категории', () {
    TailsLogger.info('событие', data: {'petId': 3});
    TailsLogger.info(
      'GET /pets/',
      category: TailsLogCategory.network,
      data: {'body': '{"name":"Рекс"}'},
    );

    expect(reporter.breadcrumbs.first.data, {'petId': 3});
    expect(reporter.breadcrumbs.last.data, isNull);
  });

  test('секреты в данных скрываются до передачи', () {
    TailsLogger.info('вход', data: {'password': 'x'});

    expect(reporter.breadcrumbs.single.data, {'password': TailsLogSanitizer.redacted});
  });

  test('ничего не делает, пока сервис не инициализирован', () {
    reporter.initialized = false;

    TailsLogger.info('шаг');

    expect(reporter.breadcrumbs, isEmpty);
  });
}

typedef _Crumb = ({
  String message,
  String category,
  BreadcrumbLevel level,
  Map<String, Object?>? data,
});

final class _Reporter implements ErrorReporter {
  bool initialized = true;
  final List<_Crumb> breadcrumbs = [];

  @override
  bool get isInitialized => initialized;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> captureException({required Object throwable, StackTrace? stackTrace}) async {}

  @override
  void addBreadcrumb({
    required String message,
    required String category,
    BreadcrumbLevel level = BreadcrumbLevel.info,
    Map<String, Object?>? data,
  }) {
    breadcrumbs.add((message: message, category: category, level: level, data: data));
  }
}
