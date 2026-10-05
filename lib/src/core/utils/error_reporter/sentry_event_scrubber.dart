import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sanitizer.dart';

/// Очищает события и breadcrumbs Sentry от персональных данных перед отправкой.
///
/// Применяет к текстам тот же [TailsLogSanitizer], что и журнал: токены, пароли и телефоны
/// не должны попасть во внешний сервис. Тела запросов, cookie, заголовки и строку запроса
/// удаляет целиком: они нужны только в локальном журнале.
final class SentryEventScrubber {
  /// Создаёт очиститель.
  const SentryEventScrubber({TailsLogSanitizer sanitizer = const TailsLogSanitizer()})
    : _sanitizer = sanitizer;

  final TailsLogSanitizer _sanitizer;

  /// Для `SentryOptions.beforeSend`.
  SentryEvent scrubEvent(SentryEvent event, Hint hint) {
    final message = event.message;
    final request = event.request;

    return event.copyWith(
      message: message == null ? null : SentryMessage(_sanitizer.sanitizeText(message.formatted)),
      exceptions: event.exceptions
          ?.map(
            (exception) => exception.copyWith(
              value: exception.value == null ? null : _sanitizer.sanitizeText(exception.value!),
            ),
          )
          .toList(),
      breadcrumbs: event.breadcrumbs?.map(_scrubBreadcrumb).toList(),
      request: request == null
          ? null
          : SentryRequest(
              url: request.url == null ? null : _sanitizer.sanitizeText(request.url!),
              method: request.method,
            ),
    );
  }

  /// Для `SentryOptions.beforeBreadcrumb`.
  Breadcrumb? scrubBreadcrumb(Breadcrumb? breadcrumb, Hint hint) =>
      breadcrumb == null ? null : _scrubBreadcrumb(breadcrumb);

  Breadcrumb _scrubBreadcrumb(Breadcrumb breadcrumb) {
    final message = breadcrumb.message;
    final data = breadcrumb.data;

    return Breadcrumb(
      message: message == null ? null : _sanitizer.sanitizeText(message),
      category: breadcrumb.category,
      data: data == null ? null : _sanitizer.sanitizeData(Map<String, Object?>.of(data)),
      level: breadcrumb.level,
      type: breadcrumb.type,
      timestamp: breadcrumb.timestamp,
    );
  }
}
