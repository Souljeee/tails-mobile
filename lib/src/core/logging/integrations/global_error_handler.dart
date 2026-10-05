import 'package:flutter/foundation.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

/// Единая точка перехвата необработанных ошибок приложения.
///
/// Ловит три источника: ошибки Flutter (`FlutterError.onError`), ошибки платформы
/// (`PlatformDispatcher.onError`) и ошибки зоны `runZonedGuarded`. Каждая попадает в журнал,
/// а оттуда — в сервис отчётов. Отправку дважды предотвращает
/// `ErrorReporterSink` (см. `ErrorReportDeduplicator`).
abstract final class GlobalErrorHandler {
  /// Устанавливает обработчики Flutter и платформы. Вызывается после
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  static void install() {
    FlutterError.onError = onFlutterError;
    PlatformDispatcher.instance.onError = onPlatformError;
  }

  /// Обработчик `FlutterError.onError`.
  ///
  /// В debug дополнительно печатает привычный для Flutter разбор ошибки в консоль.
  /// «Тихие» ошибки (`silent`, например, не загрузившаяся картинка) пишутся как
  /// предупреждения и в сервис отчётов не отправляются.
  static void onFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) FlutterError.presentError(details);

    final data = <String, Object?>{
      if (details.library != null) 'library': details.library,
      if (details.context != null) 'context': details.context!.toDescription(),
    };

    if (details.silent) {
      TailsLogger.warning(
        details.summary.toString(),
        category: TailsLogCategory.app,
        source: 'FlutterError',
        data: data,
        error: details.exception,
        stackTrace: details.stack,
      );

      return;
    }

    TailsLogger.error(
      details.summary.toString(),
      category: TailsLogCategory.app,
      source: 'FlutterError',
      data: data,
      error: details.exception,
      stackTrace: details.stack,
    );
  }

  /// Обработчик `PlatformDispatcher.onError`. Возвращает `true`: ошибка обработана.
  static bool onPlatformError(Object error, StackTrace stackTrace) {
    TailsLogger.fatal(
      'Необработанная ошибка платформы',
      category: TailsLogCategory.app,
      source: 'PlatformDispatcher',
      error: error,
      stackTrace: stackTrace,
    );

    return true;
  }

  /// Обработчик ошибок зоны `runZonedGuarded`.
  static void onZoneError(Object error, StackTrace stackTrace) {
    TailsLogger.fatal(
      'Необработанная асинхронная ошибка',
      category: TailsLogCategory.app,
      source: 'Zone',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
