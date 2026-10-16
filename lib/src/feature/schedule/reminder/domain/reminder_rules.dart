import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';

/// Единица «своего» напоминания и её границы.
enum ReminderUnit {
  minutes(1, 59),
  hours(60, 23),
  days(24 * 60, 30),
  weeks(7 * 24 * 60, 4);

  const ReminderUnit(this.minutesPerUnit, this.maxAmount);

  /// Сколько минут в одной единице.
  final int minutesPerUnit;

  /// Наибольшее число для единицы; наименьшее — [minAmount].
  final int maxAmount;

  static const int minAmount = 1;

  /// Единицы, доступные событию: у события «на весь день» нет часов и минут.
  static List<ReminderUnit> availableFor({required bool allDay}) =>
      allDay ? const [days, weeks] : values;

  /// Приводит число к границам единицы (ноль и пустое — к минимуму, лишнее — к максимуму).
  int clampAmount(int amount) =>
      amount < minAmount ? minAmount : (amount > maxAmount ? maxAmount : amount);
}

/// «Своё время»: число и единица.
class CustomReminder extends Equatable {
  /// Число приводится к границам [unit].
  CustomReminder({required int amount, required this.unit}) : amount = unit.clampAmount(amount);

  /// Начальное значение экрана «Своё время»: в списке готовых его нет.
  factory CustomReminder.initial({required bool allDay}) =>
      CustomReminder(amount: 3, unit: allDay ? ReminderUnit.days : ReminderUnit.hours);

  /// Раскладывает [minutes] на самую крупную единицу без остатка; `null`, если в границы не укладывается.
  static CustomReminder? tryFromMinutes(int minutes) {
    for (final unit in ReminderUnit.values.reversed) {
      final amount = minutes ~/ unit.minutesPerUnit;
      if (minutes % unit.minutesPerUnit == 0 &&
          amount >= ReminderUnit.minAmount &&
          amount <= unit.maxAmount) {
        return CustomReminder(amount: amount, unit: unit);
      }
    }

    return null;
  }

  final int amount;
  final ReminderUnit unit;

  int get minutes => amount * unit.minutesPerUnit;

  bool get canDecrement => amount > ReminderUnit.minAmount;

  bool get canIncrement => amount < unit.maxAmount;

  /// Смена единицы сохраняет число, но обрезает его до нового максимума.
  CustomReminder withUnit(ReminderUnit value) => CustomReminder(amount: amount, unit: value);

  CustomReminder withAmount(int value) => CustomReminder(amount: value, unit: unit);

  EventReminder toReminder() => EventReminder.before(minutes);

  @override
  List<Object?> get props => [amount, unit];
}

/// Готовые варианты, значения по умолчанию и согласование напоминания с типом и видом события.
abstract final class ReminderRules {
  static const int _day = 24 * 60;

  /// Готовые варианты события со временем, в минутах.
  static const List<int> timedPresets = [0, 10, 30, 60, _day, 2 * _day, 7 * _day];

  /// Готовые варианты события «на весь день»: в день события, накануне, за 2 дня, за неделю.
  static const List<int> allDayPresets = [0, _day, 2 * _day, 7 * _day];

  static List<int> presets({required bool allDay}) => allDay ? allDayPresets : timedPresets;

  /// Значение входит в готовые варианты («не напоминать» — отдельная карточка, не вариант).
  static bool isPreset(EventReminder reminder, {required bool allDay}) =>
      !reminder.isNone && presets(allDay: allDay).contains(reminder.minutes);

  /// Значение показывается в карточке «Своё время».
  static bool isCustom(EventReminder reminder, {required bool allDay}) =>
      !reminder.isNone && !isPreset(reminder, allDay: allDay);

  /// Напоминание по умолчанию: врач и прививки — за день, уход — за час, остальное и тип не выбран —
  /// в момент события. У события «на весь день» всегда в день события.
  static EventReminder defaultFor(ScheduleEventTypeEnum? type, {required bool allDay}) {
    if (allDay) {
      return EventReminder.atEvent;
    }

    return switch (type) {
      ScheduleEventTypeEnum.vetVisit ||
      ScheduleEventTypeEnum.yearlyVaccination ||
      ScheduleEventTypeEnum.rabiesVaccination => const EventReminder.before(_day),
      ScheduleEventTypeEnum.bathing ||
      ScheduleEventTypeEnum.grooming ||
      ScheduleEventTypeEnum.nailTrimming => const EventReminder.before(60),
      _ => EventReminder.atEvent,
    };
  }

  /// Значение, пригодное для события «на весь день»: минуты там кратны суткам.
  static EventReminder adaptTo(
    EventReminder reminder, {
    required bool allDay,
    ScheduleEventTypeEnum? type,
  }) {
    final minutes = reminder.minutes;
    if (!allDay || minutes == null || minutes % _day == 0) {
      return reminder;
    }

    return defaultFor(type, allDay: true);
  }
}

/// Когда придёт уведомление.
abstract final class ReminderSchedule {
  /// Час, от которого отсчитывается напоминание события «на весь день».
  static const int allDayHour = 9;

  /// Момент уведомления: время события (`HH:mm`, у «всего дня» 09:00) минус напоминание;
  /// `null` у «не напоминать».
  static DateTime? notifyAt({
    required DateTime date,
    required String? time,
    required EventReminder reminder,
  }) {
    final minutes = reminder.minutes;
    if (minutes == null) {
      return null;
    }

    return occurrenceAt(date: date, time: time).subtract(Duration(minutes: minutes));
  }

  /// Момент вхождения: время события либо 09:00 у события «на весь день».
  static DateTime occurrenceAt({required DateTime date, required String? time}) {
    final parts = (time ?? '').split(':');
    final hour = parts.length >= 2 ? int.tryParse(parts[0]) : null;
    final minute = parts.length >= 2 ? int.tryParse(parts[1]) : null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour ?? allDayHour,
      hour == null ? 0 : minute ?? 0,
    );
  }

  /// Момент уже наступил; «ровно сейчас» тоже считается прошедшим.
  static bool isPast(DateTime notifyAt, {required DateTime now}) => !notifyAt.isAfter(now);
}

/// Что показать под полем «Напоминание».
enum ReminderHintKind {
  /// «Придёт …».
  at,

  /// «Подобрано по типу · придёт …».
  byType,

  /// «Для каждого повторения · придёт в …».
  repeat,

  /// «Уведомление об этом событии не придёт».
  none,

  /// Время уже прошло.
  past,

  /// Уведомления выключены в системе.
  pushOff,
}

/// Правило выбора строки состояния под полем.
abstract final class ReminderHints {
  /// Порядок: «не напоминать» → прошедшее время → выключенные уведомления → серия → подбор по типу.
  ///
  /// Прошедшее время проверяется только у разового события: у серии следующие повторения придут.
  static ReminderHintKind of({
    required EventReminder reminder,
    required bool autoPicked,
    required bool typePicked,
    required bool recurring,
    required DateTime? notifyAt,
    required DateTime now,
    required bool pushBlocked,
  }) {
    if (reminder.isNone) {
      return ReminderHintKind.none;
    }
    if (!recurring && notifyAt != null && ReminderSchedule.isPast(notifyAt, now: now)) {
      return ReminderHintKind.past;
    }
    if (pushBlocked) {
      return ReminderHintKind.pushOff;
    }
    if (recurring) {
      return ReminderHintKind.repeat;
    }

    return autoPicked && typePicked ? ReminderHintKind.byType : ReminderHintKind.at;
  }
}

/// Значение поля в форме и признак, что его подобрали автоматически (пользователь не менял).
class ReminderDraft extends Equatable {
  const ReminderDraft({required this.reminder, required this.autoPicked});

  /// Новое событие: значение по типу, пока пользователь поле не менял.
  factory ReminderDraft.auto(ScheduleEventTypeEnum? type, {required bool allDay}) =>
      ReminderDraft(reminder: ReminderRules.defaultFor(type, allDay: allDay), autoPicked: true);

  /// Редактирование: сохранённое значение; у старого события (`null`) — «в момент события».
  factory ReminderDraft.saved(EventReminder? saved) =>
      ReminderDraft(reminder: saved ?? EventReminder.atEvent, autoPicked: false);

  final EventReminder reminder;
  final bool autoPicked;

  /// Пользователь выбрал значение сам: тип и вид события его больше не меняют.
  ReminderDraft picked(EventReminder value) => ReminderDraft(reminder: value, autoPicked: false);

  /// Смена типа меняет напоминание, пока его не трогали.
  ReminderDraft onTypeChanged(ScheduleEventTypeEnum? type, {required bool allDay}) =>
      autoPicked ? ReminderDraft.auto(type, allDay: allDay) : this;

  /// Переключение «со временем» / «на весь день»: подобранное значение пересчитывается, выбранное
  /// пользователем сохраняется, если подходит, иначе заменяется значением по умолчанию.
  ReminderDraft onAllDayChanged(ScheduleEventTypeEnum? type, {required bool allDay}) {
    if (autoPicked) {
      return ReminderDraft.auto(type, allDay: allDay);
    }
    final adapted = ReminderRules.adaptTo(reminder, allDay: allDay, type: type);

    return adapted == reminder ? this : ReminderDraft(reminder: adapted, autoPicked: false);
  }

  @override
  List<Object?> get props => [reminder, autoPicked];
}
