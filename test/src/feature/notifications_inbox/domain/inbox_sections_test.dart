import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/inbox_sections.dart';

import '../../../../helpers/inbox_fakes.dart';

void main() {
  // Воскресенье, 4 октября 2026, 15:00.
  final now = DateTime(2026, 10, 4, 15);

  group('calendarDaysBetween', () {
    test('считает календарные сутки, а не 24-часовые отрезки', () {
      expect(calendarDaysBetween(DateTime(2026, 10, 4, 0, 5), now), 0);
      expect(calendarDaysBetween(DateTime(2026, 10, 3, 23, 55), DateTime(2026, 10, 4, 0, 5)), 1);
      expect(calendarDaysBetween(DateTime(2026, 9, 4), now), 30);
    });

    test('не ломается на переходе месяцев и годов', () {
      expect(calendarDaysBetween(DateTime(2025, 12, 31, 23), DateTime(2026, 1, 1, 1)), 1);
    });
  });

  group('groupInboxItems', () {
    test('пустой список — нет групп', () {
      expect(groupInboxItems(const [], now), isEmpty);
    });

    test('делит на сегодня, вчера и ранее, сохраняя порядок', () {
      final items = [
        fakeInboxItem('a', createdAt: DateTime(2026, 10, 4, 14)),
        fakeInboxItem('b', createdAt: DateTime(2026, 10, 4, 0, 1)),
        fakeInboxItem('c', createdAt: DateTime(2026, 10, 3, 18, 40)),
        fakeInboxItem('d', createdAt: DateTime(2026, 10, 2, 9)),
        fakeInboxItem('e', createdAt: DateTime(2026, 9, 28)),
      ];

      final sections = groupInboxItems(items, now);

      expect(sections.map((s) => s.type), [
        InboxSectionType.today,
        InboxSectionType.yesterday,
        InboxSectionType.earlier,
      ]);
      expect(sections[0].items.map((i) => i.id), ['a', 'b']);
      expect(sections[1].items.map((i) => i.id), ['c']);
      expect(sections[2].items.map((i) => i.id), ['d', 'e']);
    });

    test('граница «Ранее» — 30 дней, дальше уведомления группируются по месяцам', () {
      final items = [
        fakeInboxItem('a', createdAt: DateTime(2026, 9, 4, 8)),
        fakeInboxItem('b', createdAt: DateTime(2026, 9, 3, 8)),
        fakeInboxItem('c', createdAt: DateTime(2026, 8, 20)),
        fakeInboxItem('d', createdAt: DateTime(2026, 8)),
      ];

      final sections = groupInboxItems(items, now);

      expect(sections.map((s) => s.type), [
        InboxSectionType.earlier,
        InboxSectionType.month,
        InboxSectionType.month,
      ]);
      expect(sections[0].items.map((i) => i.id), ['a']);
      expect(sections[1].month, DateTime(2026, 9));
      expect(sections[1].items.map((i) => i.id), ['b']);
      expect(sections[2].month, DateTime(2026, 8));
      expect(sections[2].items.map((i) => i.id), ['c', 'd']);
    });

    test('прошлый год — отдельная месячная группа', () {
      final sections = groupInboxItems([
        fakeInboxItem('a', createdAt: DateTime(2025, 12, 31)),
      ], now);

      expect(sections.single.type, InboxSectionType.month);
      expect(sections.single.month, DateTime(2025, 12));
    });

    test('время «из будущего» (часы телефона отстают) считается сегодняшним', () {
      final sections = groupInboxItems([fakeInboxItem('a', createdAt: DateTime(2026, 10, 5))], now);

      expect(sections.single.type, InboxSectionType.today);
    });
  });
}
