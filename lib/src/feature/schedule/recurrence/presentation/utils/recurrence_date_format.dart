import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';

/// Короткие даты для плашек «ближайшие даты»: «сб 26 сен», для периода «Год» — «15 мар 2027».
abstract final class RecurrenceDateFormat {
  static String pill(AppLocalizations l10n, DateTime date, {required bool withYear}) {
    final month = l10n.recurrenceMonthAbbr('${date.month}');

    return withYear
        ? '${date.day} $month ${date.year}'
        : '${l10n.recurrenceWeekdayAbbr('${date.weekday}')} ${date.day} $month';
  }
}
