import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/models/inbox_item.dart';

/// Вид группы в списке уведомлений.
enum InboxSectionType {
  today,
  yesterday,

  /// От позавчера до 30 дней назад.
  earlier,

  /// Старше 30 дней: отдельная группа на каждый месяц.
  month,
}

/// Группа уведомлений под одним заголовком.
class InboxSection extends Equatable {
  const InboxSection({required this.type, required this.items, this.month});

  final InboxSectionType type;

  /// Первое число месяца для [InboxSectionType.month].
  final DateTime? month;
  final List<InboxItem> items;

  @override
  List<Object?> get props => [type, month, items];
}

/// За сколько дней уведомления собираются в «Ранее»; старше — группируются по месяцам.
const int inboxEarlierDays = 30;

/// Разбивает [items] (от новых к старым) на группы «Сегодня», «Вчера», «Ранее» и месяцы.
///
/// Границы суток считаются по локальному времени [now].
List<InboxSection> groupInboxItems(List<InboxItem> items, DateTime now) {
  final sections = <InboxSection>[];

  for (final item in items) {
    final type = _typeOf(item.createdAt, now);
    final month = type == InboxSectionType.month
        ? DateTime(item.createdAt.year, item.createdAt.month)
        : null;

    if (sections.isNotEmpty && sections.last.type == type && sections.last.month == month) {
      final last = sections.removeLast();

      sections.add(InboxSection(type: type, month: month, items: [...last.items, item]));
    } else {
      sections.add(InboxSection(type: type, month: month, items: [item]));
    }
  }

  return sections;
}

/// Сколько календарных суток прошло от [moment] до [now] (по локальным датам).
int calendarDaysBetween(DateTime moment, DateTime now) {
  // Через UTC, чтобы переход на летнее время не давал сутки в 23 или 25 часов.
  final from = DateTime.utc(moment.year, moment.month, moment.day);
  final to = DateTime.utc(now.year, now.month, now.day);

  return to.difference(from).inDays;
}

InboxSectionType _typeOf(DateTime createdAt, DateTime now) {
  final days = calendarDaysBetween(createdAt, now);

  if (days <= 0) {
    return InboxSectionType.today;
  }

  if (days == 1) {
    return InboxSectionType.yesterday;
  }

  return days <= inboxEarlierDays ? InboxSectionType.earlier : InboxSectionType.month;
}
