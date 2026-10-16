import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/domain/reminder_rules.dart';

/// Тексты напоминания: названия значений, время уведомления, подписи единиц.
class ReminderTexts {
  const ReminderTexts(this.l10n);

  final AppLocalizations l10n;

  /// «За 1 день», «В момент события», «Не напоминать».
  String label(EventReminder reminder, {required bool allDay}) {
    final minutes = reminder.minutes;
    if (minutes == null) {
      return l10n.reminderNone;
    }
    if (allDay) {
      switch (minutes) {
        case 0:
          return l10n.reminderAllDayAtEvent;
        case 1440:
          return l10n.reminderAllDayDayBefore;
        case 2880:
          return l10n.reminderAllDayDaysBefore;
        case 10080:
          return l10n.reminderAllDayWeekBefore;
      }
    }
    if (minutes == 0) {
      return l10n.reminderAtEvent;
    }

    final custom = CustomReminder.tryFromMinutes(minutes);

    return custom == null ? l10n.reminderBeforeMinutes(minutes) : customLabel(custom);
  }

  /// «За 3 часа».
  String customLabel(CustomReminder custom) => switch (custom.unit) {
    ReminderUnit.minutes => l10n.reminderBeforeMinutes(custom.amount),
    ReminderUnit.hours => l10n.reminderBeforeHours(custom.amount),
    ReminderUnit.days => l10n.reminderBeforeDays(custom.amount),
    ReminderUnit.weeks => l10n.reminderBeforeWeeks(custom.amount),
  };

  String unitName(ReminderUnit unit) => switch (unit) {
    ReminderUnit.minutes => l10n.reminderUnitMinutes,
    ReminderUnit.hours => l10n.reminderUnitHours,
    ReminderUnit.days => l10n.reminderUnitDays,
    ReminderUnit.weeks => l10n.reminderUnitWeeks,
  };

  String unitShort(ReminderUnit unit) => switch (unit) {
    ReminderUnit.minutes => l10n.reminderUnitShortMinutes,
    ReminderUnit.hours => l10n.reminderUnitShortHours,
    ReminderUnit.days => l10n.reminderUnitShortDays,
    ReminderUnit.weeks => l10n.reminderUnitShortWeeks,
  };

  /// «Можно от 1 до 23 ч. …»; у последней единицы без «выберите следующую».
  String limit(CustomReminder custom, {required bool allDay}) {
    final units = ReminderUnit.availableFor(allDay: allDay);
    final isLast = custom.unit == units.last;
    final unit = unitShort(custom.unit);

    return isLast
        ? l10n.reminderCustomLimitLast(custom.unit.maxAmount, unit)
        : l10n.reminderCustomLimit(custom.unit.maxAmount, unit);
  }

  /// «в 14:50» в день события, иначе «пн, 19 окт. в 15:00» — для карточек и списка.
  String dateTime(DateTime notifyAt, {required DateTime event}) {
    final time = _time(notifyAt);

    return _sameDay(notifyAt, event)
        ? l10n.reminderTimeAt(time)
        : l10n.reminderDateTimeAt(_date(notifyAt), time);
  }

  /// Продолжение фразы «Придёт …»: «сегодня в 14:20», «в 14:50», «в пн, 19 окт. в 15:00».
  String when(DateTime notifyAt, {required DateTime event, required DateTime now}) {
    final time = _time(notifyAt);
    if (_sameDay(notifyAt, now)) {
      return l10n.reminderToday(time);
    }
    if (_sameDay(notifyAt, event)) {
      return l10n.reminderTimeAt(time);
    }

    return l10n.reminderPrefixOn(
      notifyAt.weekday == DateTime.tuesday ? 'tuesday' : 'other',
      l10n.reminderDateTimeAt(_date(notifyAt), time),
    );
  }

  /// Для скринридера: «в понедельник, 19 октября, в 15:00».
  String spokenWhen(DateTime notifyAt, {required DateTime event, required DateTime now}) {
    if (_sameDay(notifyAt, now) || _sameDay(notifyAt, event)) {
      return when(notifyAt, event: event, now: now);
    }

    final date = DateFormat('EEEE, d MMMM', l10n.localeName).format(notifyAt);

    return l10n.reminderPrefixOn(
      notifyAt.weekday == DateTime.tuesday ? 'tuesday' : 'other',
      l10n.reminderDateTimeAt(date, _time(notifyAt)),
    );
  }

  /// Вторая строка варианта у повторяющегося события: «Каждый раз накануне в 09:00».
  String repeatWhen(DateTime notifyAt, {required DateTime event}) {
    final time = _time(notifyAt);
    final days = DateTime(
      event.year,
      event.month,
      event.day,
    ).difference(DateTime(notifyAt.year, notifyAt.month, notifyAt.day)).inDays;

    return switch (days) {
      0 => l10n.reminderRepeatSameDay(time),
      1 => l10n.reminderRepeatDayBefore(time),
      7 => l10n.reminderRepeatWeekBefore(time),
      _ => l10n.reminderRepeatDaysBefore(days, time),
    };
  }

  /// «30 минут», «2 часа», «1 день» — сколько осталось до события.
  String left(Duration duration) {
    final minutes = duration.inMinutes < 1 ? 1 : duration.inMinutes;
    final custom = minutes < 60
        ? CustomReminder(amount: minutes, unit: ReminderUnit.minutes)
        : minutes < 1440
        ? CustomReminder(amount: minutes ~/ 60, unit: ReminderUnit.hours)
        : CustomReminder(amount: minutes ~/ 1440, unit: ReminderUnit.days);
    final text = customLabel(custom);

    // «За 30 минут» → «30 минут»: убираем предлог из готовой формы.
    return text.substring(text.indexOf(' ') + 1);
  }

  /// «вт, 20 окт.».
  String date(DateTime value) => _date(value);

  String _time(DateTime value) => DateFormat('HH:mm').format(value);

  String _date(DateTime value) => DateFormat('E, d MMM', l10n.localeName).format(value);

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Заглавная буква → строчная: «За 30 минут» → «за 30 минут» для вставки в предложение.
String lowerFirst(String value) =>
    value.isEmpty ? value : value[0].toLowerCase() + value.substring(1);
