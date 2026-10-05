import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/error_reporter.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/sentry_event_scrubber.dart';

/// {@template sentry_error_reporter}
/// An implementation of [ErrorReporter] that reports errors to Sentry.
/// {@endtemplate}
class SentryErrorReporter implements ErrorReporter {
  /// {@macro sentry_error_reporter}
  const SentryErrorReporter({
    required this.sentryDsn,
    required this.environment,
  });

  /// The Sentry DSN.
  final String sentryDsn;

  /// The Sentry environment.
  final String environment;

  @override
  bool get isInitialized => Sentry.isEnabled;

  @override
  Future<void> initialize() async {
    const scrubber = SentryEventScrubber();

    await SentryFlutter.init(
      (options) => options
        ..dsn = sentryDsn
        ..tracesSampleRate = 0.10
        ..debug = kDebugMode
        ..environment = environment
        ..anrEnabled = true
        // Персональные данные (IP, пользователь) во внешний сервис не отправляем.
        ..sendDefaultPii = false
        ..beforeSend = scrubber.scrubEvent
        ..beforeBreadcrumb = scrubber.scrubBreadcrumb,
    );
  }

  @override
  Future<void> close() async {
    await Sentry.close();
  }

  @override
  Future<void> captureException({
    required Object throwable,
    StackTrace? stackTrace,
  }) async {
    await Sentry.captureException(throwable, stackTrace: stackTrace);
  }

  @override
  void addBreadcrumb({
    required String message,
    required String category,
    BreadcrumbLevel level = BreadcrumbLevel.info,
    Map<String, Object?>? data,
  }) {
    if (!Sentry.isEnabled) return;

    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: message,
          category: category,
          level: _level(level),
          data: data,
        ),
      ),
    );
  }

  static SentryLevel _level(BreadcrumbLevel level) => switch (level) {
    BreadcrumbLevel.debug => SentryLevel.debug,
    BreadcrumbLevel.info => SentryLevel.info,
    BreadcrumbLevel.warning => SentryLevel.warning,
    BreadcrumbLevel.error => SentryLevel.error,
    BreadcrumbLevel.fatal => SentryLevel.fatal,
  };
}
