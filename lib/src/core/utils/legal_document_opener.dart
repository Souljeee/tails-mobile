import 'package:flutter/widgets.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:url_launcher/url_launcher.dart';

/// Юридические документы, ссылки на которые показывает приложение.
enum LegalDocument {
  /// Пользовательское соглашение (оферта).
  terms('terms'),

  /// Политика обработки персональных данных.
  privacy('privacy'),

  /// Согласие на обработку персональных данных.
  consent('consent');

  const LegalDocument(this.analyticsName);

  /// Значение параметра `document` в событии `legal_link_opened`.
  final String analyticsName;
}

/// Открывает юридический документ во внешнем браузере.
///
/// Пока ссылка не задана (документ не опубликован), сообщает об этом пользователю.
/// Если браузер открыть не удалось, показывает ошибку и пишет запись в журнал.
Future<void> openLegalDocument(
  BuildContext context, {
  required String url,
  required LegalDocument document,
}) async {
  final l10n = context.l10n;

  if (url.isEmpty) {
    showUiSnackBar(context, message: l10n.aboutDocumentSoon, kind: UiSnackBarKind.info);

    return;
  }

  var opened = false;
  Object? failure;
  StackTrace? failureTrace;

  try {
    final uri = Uri.tryParse(url);

    opened = uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object catch (error, stackTrace) {
    failure = error;
    failureTrace = stackTrace;
  }

  if (opened) {
    TailsAnalytics.log(TailsAnalyticsEvents.legalLinkOpened(document.analyticsName));

    return;
  }

  TailsLogger.warning(
    'Не удалось открыть юридический документ',
    source: 'openLegalDocument',
    data: {'document': document.analyticsName},
    error: failure,
    stackTrace: failureTrace,
  );

  if (context.mounted) {
    showUiSnackBar(context, message: l10n.aboutDocumentOpenError);
  }
}
