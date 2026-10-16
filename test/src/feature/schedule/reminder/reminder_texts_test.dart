import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/domain/reminder_rules.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_scope_texts.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_texts.dart';

void main() {
  late AppLocalizations l10n;
  late ReminderTexts texts;
  // Вторник, 20 октября 2026, 15:00.
  final event = DateTime(2026, 10, 20, 15);

  setUpAll(() async {
    await initializeDateFormatting('ru');
    l10n = await AppLocalizations.delegate.load(const Locale('ru'));
    texts = ReminderTexts(l10n);
  });

  test('названия значений и склонения', () {
    expect(texts.label(const EventReminder.none(), allDay: false), 'Не напоминать');
    expect(texts.label(EventReminder.atEvent, allDay: false), 'В момент события');
    expect(texts.label(const EventReminder.before(10), allDay: false), 'За 10 минут');
    expect(texts.label(const EventReminder.before(60), allDay: false), 'За 1 час');
    expect(texts.label(const EventReminder.before(180), allDay: false), 'За 3 часа');
    expect(texts.label(const EventReminder.before(1440), allDay: false), 'За 1 день');
    expect(texts.label(const EventReminder.before(2880), allDay: false), 'За 2 дня');
    expect(texts.label(const EventReminder.before(10080), allDay: false), 'За 1 неделю');
    expect(texts.label(const EventReminder.before(21), allDay: false), 'За 21 минуту');
    expect(texts.label(const EventReminder.before(11), allDay: false), 'За 11 минут');
  });

  test('«на весь день» — свои подписи готовых вариантов', () {
    expect(texts.label(EventReminder.atEvent, allDay: true), 'В день события в 09:00');
    expect(texts.label(const EventReminder.before(1440), allDay: true), 'Накануне в 09:00');
    expect(texts.label(const EventReminder.before(10080), allDay: true), 'За неделю в 09:00');
    expect(texts.label(const EventReminder.before(4320), allDay: true), 'За 3 дня');
  });

  test('время уведомления: в день события — только время', () {
    expect(texts.dateTime(DateTime(2026, 10, 20, 14, 50), event: event), 'в 14:50');
    expect(texts.dateTime(DateTime(2026, 10, 19, 15), event: event), 'пн, 19 окт. в 15:00');
  });

  test('«Придёт …»: сегодня, в день события и «во вт»', () {
    final now = DateTime(2026, 10, 10, 12);
    expect(
      texts.when(DateTime(2026, 10, 10, 14, 20), event: DateTime(2026, 10, 10, 15), now: now),
      'сегодня в 14:20',
    );
    expect(texts.when(DateTime(2026, 10, 20, 14, 50), event: event, now: now), 'в 14:50');
    expect(texts.when(DateTime(2026, 10, 19, 15), event: event, now: now), 'в пн, 19 окт. в 15:00');
    expect(
      texts.when(DateTime(2026, 10, 13, 15), event: event, now: now),
      'во вт, 13 окт. в 15:00',
    );
  });

  test('повторения: «Каждый раз …»', () {
    expect(texts.repeatWhen(DateTime(2026, 10, 20, 8, 50), event: event), 'Каждый раз в 08:50');
    expect(
      texts.repeatWhen(DateTime(2026, 10, 19, 9), event: event),
      'Каждый раз накануне в 09:00',
    );
    expect(
      texts.repeatWhen(DateTime(2026, 10, 18, 9), event: event),
      'Каждый раз за 2 дня в 09:00',
    );
    expect(
      texts.repeatWhen(DateTime(2026, 10, 13, 9), event: event),
      'Каждый раз за неделю в 09:00',
    );
  });

  test('сколько осталось до события', () {
    expect(texts.left(const Duration(minutes: 30)), '30 минут');
    expect(texts.left(const Duration(hours: 2, minutes: 10)), '2 часа');
    expect(texts.left(const Duration(days: 1, hours: 3)), '1 день');
  });

  test('подсказка о границах', () {
    expect(
      texts.limit(CustomReminder(amount: 3, unit: ReminderUnit.hours), allDay: false),
      'Можно от 1 до 23 ч. Нужно больше — выберите следующую единицу.',
    );
    expect(
      texts.limit(CustomReminder(amount: 3, unit: ReminderUnit.weeks), allDay: false),
      'Можно от 1 до 4 нед.',
    );
  });

  test('шаг «Сохранить изменения» для нового напоминания серии', () {
    final scope = ReminderScopeTexts.of(
      l10n,
      reminder: const EventReminder.before(30),
      previous: const EventReminder.before(10),
      allDay: false,
    );

    expect(scope.question, 'Новое напоминание «за 30 минут» — для каких событий?');
    expect(
      scope.oneHint,
      'В этот день напомним за 30 минут. В остальные дни — как было: за 10 минут.',
    );
    expect(
      scope.futureHint,
      'Напоминание за 30 минут для всех следующих повторений. Прошедшие не изменятся.',
    );
  });
}
