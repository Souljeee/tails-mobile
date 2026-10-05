import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tails_mobile/src/core/constant/application_config.dart';
import 'package:tails_mobile/src/core/logging/integrations/app_lifecycle_logger.dart';
import 'package:tails_mobile/src/core/logging/integrations/app_start_logger.dart';
import 'package:tails_mobile/src/core/logging/integrations/global_error_handler.dart';
import 'package:tails_mobile/src/core/logging/integrations/tails_bloc_observer.dart';
import 'package:tails_mobile/src/core/logging/sinks/console_log_sink.dart';
import 'package:tails_mobile/src/core/logging/sinks/error_reporter_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_context.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/bloc_transformer.dart';
import 'package:tails_mobile/src/feature/initialization/logic/composition_root.dart';
import 'package:tails_mobile/src/feature/initialization/widget/initialization_failed_app.dart';
import 'package:tails_mobile/src/feature/initialization/widget/root_context.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/device_info_data_source.dart';

/// {@template app_runner}
/// A class that is responsible for running the application.
/// {@endtemplate}
sealed class AppRunner {
  /// {@macro app_runner}
  const AppRunner._();

  /// Initializes dependencies and launches the application within a guarded execution zone.
  static Future<void> startup() async {
    final startupStopwatch = Stopwatch()..start();
    const config = ApplicationConfig();
    final errorReporter = await const ErrorReporterFactory(config).create();

    TailsLogContext.startSession();

    final logConfig = TailsLogConfig.forBuildMode();
    TailsLogger.configure(
      sinks: [
        ConsoleLogSink(config: logConfig),
        ErrorReporterSink(reporter: errorReporter, config: logConfig),
      ],
    );

    Intl.defaultLocale = 'ru_RU';

    await runZonedGuarded(
      () async {
        // Ensure Flutter is initialized
        WidgetsFlutterBinding.ensureInitialized();

        // Configure global error interception
        GlobalErrorHandler.install();

        // Setup bloc observer and transformer
        Bloc.observer = const TailsBlocObserver();
        Bloc.transformer = SequentialBlocTransformer().transform;

        // Состояние приложения (свернули, вернулись) пишется в журнал всё время работы.
        AppLifecycleLogger();
        await _logAppStarted(config);

        Future<void> launchApplication() async {
          try {
            final compositionResult = await CompositionRoot(
              config: config,
              errorReporter: errorReporter,
            ).compose();

            runApp(RootContext(compositionResult: compositionResult));

            WidgetsBinding.instance.addPostFrameCallback(
              (_) => TailsLogger.info(
                'Первый кадр отрисован',
                category: TailsLogCategory.app,
                source: 'AppRunner',
                data: {'sinceStartMs': startupStopwatch.elapsedMilliseconds},
              ),
            );
          } on Object catch (e, stackTrace) {
            TailsLogger.fatal(
              'Не удалось инициализировать приложение',
              category: TailsLogCategory.app,
              source: 'AppRunner',
              error: e,
              stackTrace: stackTrace,
            );
            runApp(
              InitializationFailedApp(
                error: e,
                stackTrace: stackTrace,
                onRetryInitialization: launchApplication,
              ),
            );
          }
        }

        // Launch the application
        await launchApplication();
      },
      GlobalErrorHandler.onZoneError,
    );
  }

  /// Пишет сведения о сборке и устройстве. Сбой не должен задерживать или ломать запуск.
  static Future<void> _logAppStarted(ApplicationConfig config) async {
    try {
      final (packageInfo, device) = await (
        PackageInfo.fromPlatform(),
        const DeviceInfoDataSource().load(),
      ).wait.timeout(const Duration(seconds: 2));

      AppStartLogger.log(
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        environment: config.environment.value,
        platform: device.platform,
        osVersion: device.osVersion,
        deviceModel: device.deviceModel,
      );
    } on Object catch (e, stackTrace) {
      TailsLogger.warning(
        'Не удалось собрать сведения о запуске',
        category: TailsLogCategory.app,
        source: 'AppRunner',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
