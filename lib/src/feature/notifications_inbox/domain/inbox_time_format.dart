import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/inbox_sections.dart';

/// Подпись времени уведомления: «5 мин» и «2 ч» сегодня, «18:40» вчера, «28 сент.» раньше
/// в этом году и «12.08.2025» в прошлых.
String formatInboxTime(AppLocalizations l10n, DateTime createdAt, DateTime now) {
  final days = calendarDaysBetween(createdAt, now);

  if (days <= 0) {
    final elapsed = now.difference(createdAt);

    if (elapsed.inMinutes < 60) {
      // Уведомление не может быть «0 мин назад», а часы телефона могут чуть опережать сервер.
      return l10n.inboxTimeMinutes(elapsed.inMinutes < 1 ? 1 : elapsed.inMinutes);
    }

    return l10n.inboxTimeHours(elapsed.inHours);
  }

  if (days == 1) {
    return DateFormat.Hm(l10n.localeName).format(createdAt);
  }

  return createdAt.year == now.year
      ? DateFormat('d MMM', l10n.localeName).format(createdAt)
      : DateFormat('dd.MM.yyyy', l10n.localeName).format(createdAt);
}

/// Заголовок месячной группы: «Август» или «Август 2025» для прошлых лет.
String formatInboxMonth(DateTime month, DateTime now, [String? locale]) {
  final text = month.year == now.year
      ? DateFormat('LLLL', locale).format(month)
      : DateFormat('LLLL y', locale).format(month);

  return text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
}
