import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';

/// Подпись дня события: «Сегодня», «Завтра» или `d MMMM`.
///
/// Для события без времени сегодня возвращает «Весь день», для остальных дат
/// добавляет «· Весь день».
String formatEventDayLabel({
  required AppLocalizations l10n,
  required String locale,
  required DateTime date,
  required DateTime now,
  required bool isAllDay,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final difference = DateTime(date.year, date.month, date.day).difference(today).inDays;

  if (difference == 0) {
    return isAllDay ? l10n.scheduleAllDay : l10n.petNextEventToday;
  }

  final day = difference == 1
      ? l10n.petNextEventTomorrow
      : DateFormat('d MMMM', locale).format(date);

  return isAllDay ? '$day · ${l10n.scheduleAllDay}' : day;
}
