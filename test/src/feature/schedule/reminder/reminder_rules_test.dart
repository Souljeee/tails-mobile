import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/domain/reminder_rules.dart';

void main() {
  group('EventReminder', () {
    test('wire round trip', () {
      expect(const EventReminder.none().toWire(), <int>[]);
      expect(const EventReminder.before(30).toWire(), [30]);
      expect(EventReminder.atEvent.toWire(), [0]);
      expect(EventReminder.fromWire(null), isNull);
      expect(EventReminder.fromWire([]), const EventReminder.none());
      expect(EventReminder.fromWire([60]), const EventReminder.before(60));
    });
  });

  group('CustomReminder', () {
    test('clamps amount to unit limits', () {
      expect(CustomReminder(amount: 0, unit: ReminderUnit.hours).amount, 1);
      expect(CustomReminder(amount: 99, unit: ReminderUnit.hours).amount, 23);
      expect(CustomReminder(amount: 9, unit: ReminderUnit.weeks).amount, 4);
    });

    test('withUnit clamps amount', () {
      final custom = CustomReminder(amount: 30, unit: ReminderUnit.days);
      expect(custom.withUnit(ReminderUnit.weeks).amount, 4);
    });

    test('limits match server maximum of 43200 minutes', () {
      expect(CustomReminder(amount: 30, unit: ReminderUnit.days).minutes, 43200);
      expect(CustomReminder(amount: 4, unit: ReminderUnit.weeks).minutes, lessThanOrEqualTo(43200));
    });

    test('tryFromMinutes picks the largest exact unit', () {
      expect(
        CustomReminder.tryFromMinutes(180),
        CustomReminder(amount: 3, unit: ReminderUnit.hours),
      );
      expect(
        CustomReminder.tryFromMinutes(14 * 1440),
        CustomReminder(amount: 2, unit: ReminderUnit.weeks),
      );
      expect(
        CustomReminder.tryFromMinutes(45),
        CustomReminder(amount: 45, unit: ReminderUnit.minutes),
      );
      expect(CustomReminder.tryFromMinutes(0), isNull);
      expect(CustomReminder.tryFromMinutes(43201), isNull);
    });

    test('all-day units are days and weeks', () {
      expect(ReminderUnit.availableFor(allDay: true), [ReminderUnit.days, ReminderUnit.weeks]);
    });

    test('increment and decrement flags', () {
      final low = CustomReminder(amount: 1, unit: ReminderUnit.days);
      final high = CustomReminder(amount: 30, unit: ReminderUnit.days);
      expect(low.canDecrement, isFalse);
      expect(high.canIncrement, isFalse);
    });
  });

  group('ReminderRules', () {
    test('defaults by type', () {
      ScheduleEventTypeEnum? t;
      expect(ReminderRules.defaultFor(t, allDay: false), EventReminder.atEvent);
      expect(
        ReminderRules.defaultFor(ScheduleEventTypeEnum.vetVisit, allDay: false),
        const EventReminder.before(1440),
      );
      expect(
        ReminderRules.defaultFor(ScheduleEventTypeEnum.bathing, allDay: false),
        const EventReminder.before(60),
      );
      expect(
        ReminderRules.defaultFor(ScheduleEventTypeEnum.walking, allDay: false),
        EventReminder.atEvent,
      );
      expect(
        ReminderRules.defaultFor(ScheduleEventTypeEnum.vetVisit, allDay: true),
        EventReminder.atEvent,
      );
    });

    test('preset and custom classification', () {
      expect(ReminderRules.isPreset(const EventReminder.before(30), allDay: false), isTrue);
      expect(ReminderRules.isCustom(const EventReminder.before(45), allDay: false), isTrue);
      expect(ReminderRules.isPreset(const EventReminder.before(30), allDay: true), isFalse);
      expect(ReminderRules.isCustom(const EventReminder.none(), allDay: false), isFalse);
    });

    test('готовые варианты со временем начинаются с 5 минут', () {
      expect(ReminderRules.presets(allDay: false).take(3), [0, 5, 10]);
      expect(ReminderRules.isPreset(const EventReminder.before(5), allDay: false), isTrue);
    });

    test('adaptTo keeps day multiples and replaces others for all-day', () {
      expect(
        ReminderRules.adaptTo(const EventReminder.before(2880), allDay: true),
        const EventReminder.before(2880),
      );
      expect(
        ReminderRules.adaptTo(const EventReminder.before(30), allDay: true),
        EventReminder.atEvent,
      );
      expect(
        ReminderRules.adaptTo(const EventReminder.none(), allDay: true),
        const EventReminder.none(),
      );
    });
  });

  group('ReminderSchedule', () {
    final date = DateTime(2026, 10, 20);

    test('notifyAt subtracts minutes', () {
      expect(
        ReminderSchedule.notifyAt(
          date: date,
          time: '15:00',
          reminder: const EventReminder.before(10),
        ),
        DateTime(2026, 10, 20, 14, 50),
      );
      expect(
        ReminderSchedule.notifyAt(
          date: date,
          time: null,
          reminder: const EventReminder.before(1440),
        ),
        DateTime(2026, 10, 19, 9),
      );
      expect(
        ReminderSchedule.notifyAt(date: date, time: '15:00', reminder: const EventReminder.none()),
        isNull,
      );
    });

    test('isPast treats now as past', () {
      final now = DateTime(2026, 10, 20, 12);
      expect(ReminderSchedule.isPast(now, now: now), isTrue);
      expect(ReminderSchedule.isPast(now.add(const Duration(minutes: 1)), now: now), isFalse);
    });
  });

  group('ReminderHints', () {
    final now = DateTime(2026, 10, 20, 12);
    final future = DateTime(2026, 10, 21);
    ReminderHintKind of({
      EventReminder reminder = EventReminder.atEvent,
      bool autoPicked = false,
      bool typePicked = true,
      bool recurring = false,
      DateTime? notifyAt,
      bool pushBlocked = false,
    }) => ReminderHints.of(
      reminder: reminder,
      autoPicked: autoPicked,
      typePicked: typePicked,
      recurring: recurring,
      notifyAt: notifyAt ?? future,
      now: now,
      pushBlocked: pushBlocked,
    );

    test('none wins over everything', () {
      expect(of(reminder: const EventReminder.none(), pushBlocked: true), ReminderHintKind.none);
    });

    test('past beats push off, push off beats others', () {
      expect(of(notifyAt: DateTime(2026, 10, 20, 11), pushBlocked: true), ReminderHintKind.past);
      expect(of(pushBlocked: true, autoPicked: true), ReminderHintKind.pushOff);
    });

    test('recurring skips past check', () {
      expect(of(recurring: true, notifyAt: DateTime(2026, 10, 20, 11)), ReminderHintKind.repeat);
    });

    test('by type only when auto picked and type chosen', () {
      expect(of(autoPicked: true), ReminderHintKind.byType);
      expect(of(autoPicked: true, typePicked: false), ReminderHintKind.at);
      expect(of(), ReminderHintKind.at);
    });
  });

  group('ReminderDraft', () {
    test('type change updates only auto picked draft', () {
      final auto = ReminderDraft.auto(null, allDay: false);
      expect(
        auto.onTypeChanged(ScheduleEventTypeEnum.vetVisit, allDay: false).reminder,
        const EventReminder.before(1440),
      );
      final picked = auto.picked(const EventReminder.before(10));
      expect(picked.onTypeChanged(ScheduleEventTypeEnum.vetVisit, allDay: false), picked);
    });

    test('all-day switch recomputes auto, adapts picked', () {
      final auto = ReminderDraft.auto(ScheduleEventTypeEnum.vetVisit, allDay: false);
      expect(
        auto.onAllDayChanged(ScheduleEventTypeEnum.vetVisit, allDay: true).reminder,
        EventReminder.atEvent,
      );
      final picked = ReminderDraft.saved(const EventReminder.before(30));
      final adapted = picked.onAllDayChanged(null, allDay: true);
      expect(adapted.reminder, EventReminder.atEvent);
      expect(adapted.autoPicked, isFalse);
      final keep = ReminderDraft.saved(const EventReminder.before(1440));
      expect(keep.onAllDayChanged(null, allDay: true), keep);
    });

    test('saved null reads as at event', () {
      expect(ReminderDraft.saved(null).reminder, EventReminder.atEvent);
    });
  });
}
