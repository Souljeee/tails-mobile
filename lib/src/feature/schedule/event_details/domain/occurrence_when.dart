import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';

/// Когда состоится вхождение: «Сегодня, 17:05», «Завтра», «Вт, 20 октября, 17:05».
///
/// [time] — локальное `HH:mm` или `HH:mm:ss`; `null` у события на весь день (тогда в строке
/// только день, а для сегодняшнего дня — «Весь день»).
String formatOccurrenceWhen({
  required AppLocalizations l10n,
  required DateTime date,
  required DateTime now,
  String? time,
}) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final difference = day.difference(today).inDays;
  final locale = l10n.localeName;

  final dayText = switch (difference) {
    0 => l10n.petNextEventToday,
    1 => l10n.petNextEventTomorrow,
    _ => l10n.eventDetailsDateWithWeekday(
      toBeginningOfSentenceCase(DateFormat.E(locale).format(day), locale),
      DateFormat('d MMMM', locale).format(day),
    ),
  };

  if (time == null) {
    return difference == 0 ? l10n.scheduleAllDay : dayText;
  }

  return l10n.eventDetailsDateTime(dayText, shortTime(time));
}

/// `HH:mm:ss` → `HH:mm`.
String shortTime(String time) => time.length >= 5 ? time.substring(0, 5) : time;
