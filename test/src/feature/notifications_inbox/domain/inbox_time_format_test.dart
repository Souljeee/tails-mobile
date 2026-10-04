import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations_ru.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/inbox_time_format.dart';

void main() {
  final l10n = AppLocalizationsRu();
  final now = DateTime(2026, 10, 4, 15);

  setUpAll(() async {
    await initializeDateFormatting('ru_RU');
    Intl.defaultLocale = 'ru_RU';
  });

  group('formatInboxTime', () {
    test('сегодня: минуты', () {
      expect(formatInboxTime(l10n, DateTime(2026, 10, 4, 14, 55), now), '5 мин');
      expect(formatInboxTime(l10n, DateTime(2026, 10, 4, 14, 1), now), '59 мин');
    });

    test('сегодня: меньше минуты показывается как «1 мин»', () {
      expect(formatInboxTime(l10n, now, now), '1 мин');
      expect(formatInboxTime(l10n, now.add(const Duration(minutes: 3)), now), '1 мин');
    });

    test('сегодня: часы', () {
      expect(formatInboxTime(l10n, DateTime(2026, 10, 4, 14), now), '1 ч');
      expect(formatInboxTime(l10n, DateTime(2026, 10, 4, 12, 30), now), '2 ч');
      expect(formatInboxTime(l10n, DateTime(2026, 10, 4, 0, 10), now), '14 ч');
    });

    test('вчера: время', () {
      expect(formatInboxTime(l10n, DateTime(2026, 10, 3, 18, 40), now), '18:40');
      expect(formatInboxTime(l10n, DateTime(2026, 10, 3, 9, 5), now), '09:05');
    });

    test('раньше в этом году: день и месяц', () {
      expect(formatInboxTime(l10n, DateTime(2026, 9, 28, 10), now), '28 сент.');
      expect(formatInboxTime(l10n, DateTime(2026, 1, 5, 10), now), '5 янв.');
    });

    test('прошлые годы: полная дата', () {
      expect(formatInboxTime(l10n, DateTime(2025, 8, 12, 10), now), '12.08.2025');
    });
  });

  group('formatInboxMonth', () {
    test('месяц этого года с заглавной буквы', () {
      expect(formatInboxMonth(DateTime(2026, 8), now), 'Август');
    });

    test('прошлый год — с годом', () {
      expect(formatInboxMonth(DateTime(2025, 12), now), 'Декабрь 2025');
    });
  });
}
