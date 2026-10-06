import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:tails_mobile/src/core/analytics/sinks/appmetrica_analytics_sink.dart';
import 'package:tails_mobile/src/core/analytics/sinks/firebase_analytics_sink.dart';
import 'package:tails_mobile/src/core/analytics/sinks/log_analytics_sink.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_sink.dart';
import 'package:tails_mobile/src/core/constant/application_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/feature/initialization/model/environment.dart';

/// Создаёт приёмники аналитики по конфигурации сборки.
///
/// Сбой любого сервиса не мешает запуску: приёмник просто не подключается.
final class TailsAnalyticsSinkFactory {
  /// Создаёт фабрику.
  const TailsAnalyticsSinkFactory(this.config);

  /// Конфигурация приложения.
  final ApplicationConfig config;

  static const _timeout = Duration(seconds: 3);

  /// Возвращает список готовых приёмников.
  Future<List<TailsAnalyticsSink>> create() async {
    final sinks = <TailsAnalyticsSink>[if (!kReleaseMode) const LogAnalyticsSink()];

    final appMetrica = await _guard('AppMetrica', _createAppMetrica);
    if (appMetrica != null) sinks.add(appMetrica);

    // Firebase Analytics собирает данные только в production.
    if (config.environment == Environment.prod) {
      final firebase = await _guard('Firebase Analytics', _createFirebase);
      if (firebase != null) sinks.add(firebase);
    }

    return sinks;
  }

  Future<TailsAnalyticsSink?> _createAppMetrica() async {
    final apiKey = config.appMetricaApiKey;
    if (apiKey.isEmpty) return null;

    await PluginAppMetricaClient.activate(apiKey: apiKey, logs: !kReleaseMode);

    return const AppMetricaAnalyticsSink();
  }

  Future<TailsAnalyticsSink?> _createFirebase() async {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    const sink = FirebaseAnalyticsSink();
    await sink.enableCollection();

    return sink;
  }

  Future<TailsAnalyticsSink?> _guard(
    String name,
    Future<TailsAnalyticsSink?> Function() create,
  ) async {
    try {
      return await create().timeout(_timeout);
    } on Object catch (e, stackTrace) {
      TailsLogger.warning(
        'Аналитика недоступна: $name',
        category: TailsLogCategory.app,
        source: 'TailsAnalytics',
        error: e,
        stackTrace: stackTrace,
      );

      return null;
    }
  }
}
