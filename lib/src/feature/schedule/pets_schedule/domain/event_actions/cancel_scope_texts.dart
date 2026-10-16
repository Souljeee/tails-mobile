import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/series_stats.dart';

/// Подписи шага отмены повторяющегося события (чистая логика поверх локализации).
///
/// [stats] — сводка сервера на дату вхождения: сколько событий осталось и сколько было.
/// Если остаток — одно событие, выбора области нет: «все следующие» совпадает с «только это», и
/// шаг выглядит как отмена одиночного события.
class CancelScopeTexts {
  CancelScopeTexts(this._l10n, {required this.date, required this.stats});

  final AppLocalizations _l10n;
  final DateTime date;
  final SeriesStats stats;

  /// Выбор области не нужен: осталось последнее событие серии.
  bool get isSingleChoice => stats.isLastOccurrence;

  String get _dateText => DateFormat.MMMMd(_l10n.localeName).format(date);

  /// Радио «Только 16 октября».
  String get oneLabel => _l10n.eventCancelScopeOne(_dateText);

  /// Радио «16 октября и все следующие».
  String get futureLabel => _l10n.eventCancelScopeFuture(_dateText);

  /// Кнопка подтверждения для области «только эта дата» (и для последнего события серии).
  String get confirmOne => _l10n.eventCancelConfirmOne;

  /// Кнопка подтверждения для области «и все следующие»: «Отменить 335 событий»; у бессрочной
  /// серии число неизвестно.
  String get confirmFuture {
    final remaining = stats.remaining;

    return remaining == null || stats.isOpenEnded
        ? _l10n.eventCancelConfirmFuture
        : _l10n.eventCancelConfirmCount(remaining);
  }

  /// Пояснение под областью «и все следующие»; `null`, если сказать нечего.
  String? get futureHint {
    if (stats.isOpenEnded) {
      return _l10n.eventCancelFutureOpenEndedHint;
    }

    return stats.past > 0 ? _l10n.eventCancelPastKept(stats.past) : null;
  }

  /// Пояснение для последнего события серии.
  String? get lastInSeriesHint => isSingleChoice ? _l10n.eventCancelLastInSeries : null;
}
