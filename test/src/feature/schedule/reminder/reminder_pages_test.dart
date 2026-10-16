import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_custom_page.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_page.dart';

void main() {
  // Сейчас 14:00, событие сегодня в 14:30 (флоу R3).
  final now = DateTime(2026, 10, 20, 14);
  final eventAt = DateTime(2026, 10, 20, 14, 30);

  Future<void> pump(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: UiThemeData.lightTheme,
        locale: const Locale('ru'),
        localizationsDelegates: Localization.localizationDelegates,
        supportedLocales: Localization.supportedLocales,
        home: Scaffold(body: page),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ReminderPage', () {
    testWidgets('прошедшие варианты недоступны, сверху плашка', (tester) async {
      final selected = <EventReminder>[];
      await pump(
        tester,
        ReminderPage(
          reminder: const EventReminder.before(60),
          eventAt: eventAt,
          allDay: false,
          recurring: false,
          now: now,
          onSelected: selected.add,
          onOpenCustom: () {},
          onBack: () {},
        ),
      );

      expect(
        find.text('Событие уже через 30 минут. Варианты, время которых прошло, недоступны.'),
        findsOneWidget,
      );
      expect(find.text('уже прошло'), findsOneWidget);
      // «За 30 минут» — ровно сейчас, тоже прошло.
      expect(find.text('Уже прошло'), findsNWidgets(5));

      await tester.tap(find.text('За 1 день'));
      await tester.tap(find.text('За 10 минут'));
      await tester.pump();

      expect(selected, [const EventReminder.before(10)]);
    });

    testWidgets('у серии варианты не блокируются и пишутся «Каждый раз …»', (tester) async {
      await pump(
        tester,
        ReminderPage(
          reminder: const EventReminder.before(10),
          eventAt: eventAt,
          allDay: false,
          recurring: true,
          now: now,
          onSelected: (_) {},
          onOpenCustom: () {},
          onBack: () {},
        ),
      );

      expect(find.text('Уже прошло'), findsNothing);
      expect(find.text('Каждый раз в 14:20'), findsOneWidget);
      expect(find.text('Каждый раз накануне в 14:30'), findsOneWidget);
      expect(find.text('Напоминание сработает перед каждым повторением события.'), findsOneWidget);
    });
  });

  group('ReminderCustomPage', () {
    Widget page({
      EventReminder current = EventReminder.atEvent,
      DateTime? at,
      ValueChanged<EventReminder>? onApply,
    }) => ReminderCustomPage(
      current: current,
      eventAt: at ?? DateTime(2026, 10, 25, 15),
      allDay: false,
      recurring: false,
      now: now,
      onApply: onApply ?? (_) {},
      onBack: () {},
    );

    testWidgets('смена единицы обрезает число до максимума', (tester) async {
      await pump(tester, page(current: const EventReminder.before(20 * 1440)));

      expect(find.text('За 20 дней'), findsOneWidget);

      await tester.tap(find.text('Недели'));
      await tester.pumpAndSettle();

      expect(find.text('За 4 недели'), findsOneWidget);
      expect(find.text('Можно от 1 до 4 нед.'), findsOneWidget);
    });

    testWidgets('ввод с клавиатуры: больше максимума — максимум, ноль — единица', (tester) async {
      EventReminder? applied;
      await pump(tester, page(onApply: (value) => applied = value));

      await tester.enterText(find.byType(TextField), '99');
      await tester.pump();
      expect(find.text('За 23 часа'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '0');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(find.text('За 1 час'), findsOneWidget);

      await tester.tap(find.text('Готово'));
      expect(applied, const EventReminder.before(60));
    });

    testWidgets('прошедшее время: «Готово» недоступна, в карточке «уже прошло»', (tester) async {
      await pump(tester, page(at: eventAt));

      expect(find.text('уже прошло'), findsOneWidget);
      expect(tester.widget<UiButton>(find.byType(UiButton)).onPressed, isNull);
    });
  });
}
