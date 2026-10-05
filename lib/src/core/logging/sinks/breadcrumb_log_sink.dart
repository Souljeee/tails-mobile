import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sink.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/error_reporter.dart';

/// Передаёт важные записи журнала в сервис отчётов как breadcrumbs («хлебные крошки»).
///
/// При ошибке в Sentry видно, что происходило перед ней: переходы, запросы, шаги сценария.
/// Берутся записи от [TailsLogConfig.breadcrumbMinLevel] и выше. Структурированные данные
/// сетевых записей (заголовки, тела) не передаются: они остаются только в локальном журнале.
final class BreadcrumbLogSink implements TailsLogSink {
  /// Создаёт sink.
  BreadcrumbLogSink({required ErrorReporter reporter, required TailsLogConfig config})
    : _reporter = reporter,
      _config = config;

  final ErrorReporter _reporter;
  final TailsLogConfig _config;

  @override
  bool isEnabled(TailsLogLevel level, TailsLogCategory category) =>
      level.isAtLeast(_config.breadcrumbMinLevel) && _reporter.isInitialized;

  @override
  void write(TailsLogEvent event) {
    final source = event.source;

    _reporter.addBreadcrumb(
      message: source == null ? event.message : '$source: ${event.message}',
      category: event.category.name,
      level: _level(event.level),
      data: event.category == TailsLogCategory.network || event.data.isEmpty ? null : event.data,
    );
  }

  static BreadcrumbLevel _level(TailsLogLevel level) => switch (level) {
    TailsLogLevel.trace || TailsLogLevel.debug => BreadcrumbLevel.debug,
    TailsLogLevel.info => BreadcrumbLevel.info,
    TailsLogLevel.warning => BreadcrumbLevel.warning,
    TailsLogLevel.error => BreadcrumbLevel.error,
    TailsLogLevel.fatal => BreadcrumbLevel.fatal,
  };
}
