import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations_ru.dart';
import 'package:tails_mobile/src/feature/schedule/event_details/domain/occurrence_when.dart';

void main() {
  setUpAll(() => initializeDateFormatting('ru'));

  final l10n = AppLocalizationsRu();
  final now = DateTime(2026, 10, 16, 9, 30);

  String when(DateTime date, {String? time}) =>
      formatOccurrenceWhen(l10n: l10n, date: date, now: now, time: time);

  test('сегодня и завтра со временем', () {
    expect(when(DateTime(2026, 10, 16), time: '17:05:00'), 'Сегодня, 17:05');
    expect(when(DateTime(2026, 10, 17), time: '08:00'), 'Завтра, 08:00');
  });

  test('другой день: день недели с большой буквы, число и месяц', () {
    expect(when(DateTime(2026, 10, 20), time: '17:05:00'), 'Вт, 20 октября, 17:05');
    expect(when(DateTime(2026, 10, 15), time: '17:05'), 'Чт, 15 октября, 17:05');
  });

  test('событие на весь день: без времени', () {
    expect(when(DateTime(2026, 10, 16)), 'Весь день');
    expect(when(DateTime(2026, 10, 17)), 'Завтра');
    expect(when(DateTime(2026, 10, 20)), 'Вт, 20 октября');
  });

  test('время суток в now и date не влияет на разницу дней', () {
    expect(
      formatOccurrenceWhen(
        l10n: l10n,
        date: DateTime(2026, 10, 17, 23, 59),
        now: DateTime(2026, 10, 16, 0, 1),
        time: '10:00',
      ),
      'Завтра, 10:00',
    );
  });

  test('shortTime', () {
    expect(shortTime('09:05:00'), '09:05');
    expect(shortTime('09:05'), '09:05');
  });
}
