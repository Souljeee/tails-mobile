import 'dart:async';

import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';

/// Переводит исключение в закрытую причину для событий `*_failed`.
///
/// Текст ошибки в аналитику не попадает: он может содержать данные пользователя.
/// Причины, специфичные для фичи (например, неверный код), блок определяет сам до вызова.
AnalyticsReason analyticsReasonOf(Object error) => switch (error) {
  TimeoutException() => AnalyticsReason.timeout,
  ConnectionException() => AnalyticsReason.network,
  InternalServerException() => AnalyticsReason.server,
  final RestClientException e => _byStatus(e.statusCode),
  _ => AnalyticsReason.unknown,
};

AnalyticsReason _byStatus(int? status) => switch (status) {
  null => AnalyticsReason.unknown,
  400 || 422 => AnalyticsReason.validation,
  401 || 403 => AnalyticsReason.unauthorized,
  404 => AnalyticsReason.notFound,
  429 => AnalyticsReason.rateLimited,
  >= 500 => AnalyticsReason.server,
  _ => AnalyticsReason.unknown,
};
