import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/analytics/analytics_reporter.dart';

/// {@template firebase_analytics_reporter}
/// An implementation of [AnalyticsReporter] that reports events to Firebase
/// Analytics.
/// {@endtemplate}
final class FirebaseAnalyticsReporter implements AnalyticsReporter {
  /// {@macro firebase_analytics_reporter}
  const FirebaseAnalyticsReporter({required this.analytics});

  /// The Firebase Analytics instance used to log events.
  final FirebaseAnalytics analytics;

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    final parameters = event.parameters?.map(
      (parameter) => MapEntry(parameter.name, parameter.value),
    );

    TailsLogger.trace(
      'Событие аналитики ${event.name}',
      source: 'FirebaseAnalyticsReporter',
      data: {if (parameters != null) 'parameters': Map.fromEntries(parameters)},
    );

    await analytics.logEvent(
      name: event.name,
      parameters: parameters != null ? Map.fromEntries(parameters) : null,
    );
  }
}
