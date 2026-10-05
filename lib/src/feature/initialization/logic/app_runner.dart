import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/constant/application_config.dart';
import 'package:tails_mobile/src/core/logging/integrations/global_error_handler.dart';
import 'package:tails_mobile/src/core/logging/integrations/tails_bloc_observer.dart';
import 'package:tails_mobile/src/core/logging/sinks/console_log_sink.dart';
import 'package:tails_mobile/src/core/logging/sinks/error_reporter_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/bloc_transformer.dart';
import 'package:tails_mobile/src/feature/initialization/logic/composition_root.dart';
import 'package:tails_mobile/src/feature/initialization/widget/initialization_failed_app.dart';
import 'package:tails_mobile/src/feature/initialization/widget/root_context.dart';

/// {@template app_runner}
/// A class that is responsible for running the application.
/// {@endtemplate}
sealed class AppRunner {
  /// {@macro app_runner}
  const AppRunner._();

  /// Initializes dependencies and launches the application within a guarded execution zone.
  static Future<void> startup() async {
    const config = ApplicationConfig();
    final errorReporter = await const ErrorReporterFactory(config).create();

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

        Future<void> launchApplication() async {
          try {
            final compositionResult = await CompositionRoot(
              config: config,
              errorReporter: errorReporter,
            ).compose();

            runApp(RootContext(compositionResult: compositionResult));
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
}
