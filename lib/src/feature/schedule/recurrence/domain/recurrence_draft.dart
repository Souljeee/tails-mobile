import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_calculator.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_limits.dart';

/// Редактируемое состояние экрана «Повторение» (чистый Dart, без Flutter).
///
/// Хранит настройки **всех** периодов: переключение День/Неделя/Месяц/Год ничего не стирает,
/// а [toModel] отдаёт только выбранный период. Все методы возвращают новый черновик.
///
/// Правила редактора: интервал и число повторений ограничены [RecurrenceLimits]; последний
/// выбранный день недели / число месяца / дату года / время снять нельзя; времена всегда
/// отсортированы и без дублей; значения по умолчанию берутся из даты и времени события, пока
/// пользователь их не менял ([rebase] обновляет только нетронутые).
class RecurrenceDraft extends Equatable {
  const RecurrenceDraft._({
    required this.period,
    required this.intervals,
    required this.weekDays,
    required this.monthDays,
    required this.yearDates,
    required this.times,
    required this.end,
    required this.eventDate,
    required this.eventTime,
    required this.weekDaysTouched,
    required this.monthDaysTouched,
    required this.yearDatesTouched,
    required this.timesEdited,
  });

  /// Черновик для нового повторения: «Каждый день», значения из даты и времени события.
  factory RecurrenceDraft.initial({required DateTime eventDate, String? eventTime}) {
    final time = LocalTime.tryParse(eventTime);

    return RecurrenceDraft._(
      period: RecurrencePeriod.day,
      intervals: const {},
      weekDays: [eventDate.weekday],
      monthDays: [MonthDay(eventDate.day)],
      yearDates: [YearDate(eventDate.month, eventDate.day)],
      times: time == null ? const [] : [time],
      end: const RecurrenceEnd.never(),
      eventDate: _day(eventDate),
      eventTime: time,
      weekDaysTouched: false,
      monthDaysTouched: false,
      yearDatesTouched: false,
      timesEdited: false,
    );
  }

  /// Черновик из существующего правила (редактирование).
  factory RecurrenceDraft.fromModel(
    RecurrenceModel rule, {
    required DateTime eventDate,
    String? eventTime,
  }) {
    final base = RecurrenceDraft.initial(eventDate: eventDate, eventTime: eventTime);
    final period = rule.period == RecurrencePeriod.unknown ? RecurrencePeriod.day : rule.period;

    return base._copy(
      period: period,
      intervals: {period: rule.interval},
      weekDays: rule.weekDays.isEmpty ? null : rule.weekDays,
      monthDays: rule.monthDays.isEmpty ? null : rule.monthDays,
      yearDates: rule.yearDates.isEmpty ? null : rule.yearDates,
      times: rule.times.length > 1 ? rule.times : null,
      end: rule.end,
      weekDaysTouched: rule.weekDays.isNotEmpty,
      monthDaysTouched: rule.monthDays.isNotEmpty,
      yearDatesTouched: rule.yearDates.isNotEmpty,
      timesEdited: rule.times.length > 1,
    );
  }

  final RecurrencePeriod period;

  /// Интервал по периодам; нет записи — 1.
  final Map<RecurrencePeriod, int> intervals;
  final List<int> weekDays;
  final List<MonthDay> monthDays;
  final List<YearDate> yearDates;

  /// Времена в день (локальные, по возрастанию); пусто, если у события нет времени («весь день»).
  final List<LocalTime> times;
  final RecurrenceEnd end;

  final DateTime eventDate;
  final LocalTime? eventTime;

  final bool weekDaysTouched;
  final bool monthDaysTouched;
  final bool yearDatesTouched;
  final bool timesEdited;

  static const _weekdays = [1, 2, 3, 4, 5];
  static const _weekend = [6, 7];

  int get interval => intervals[period] ?? 1;

  /// Можно ли задавать несколько времён в день (нужно время события).
  bool get supportsTimes => eventTime != null;

  int get timesCount => times.length;

  /// Дни 29–31 в «Месяц»: в коротких месяцах переносятся на последний день.
  bool get hasMonthTransfer => monthDays.any((d) => !d.isLast && d.value >= 29);

  /// 29 февраля в «Год»: в невисокосный год переносится на 28 февраля.
  bool get hasFeb29 => yearDates.any((d) => d.isFeb29);

  bool get isWeekdaysPreset => _same(weekDays, _weekdays);
  bool get isWeekendPreset => _same(weekDays, _weekend);
  bool get isAllDaysPreset => weekDays.length == 7;

  // --- период и интервал ---

  RecurrenceDraft withPeriod(RecurrencePeriod value) => _copy(period: value);

  RecurrenceDraft withInterval(int value) {
    final clamped = value.clamp(1, RecurrenceLimits.maxInterval(period));

    return _copy(intervals: {...intervals, period: clamped});
  }

  // --- дни недели ---

  /// Включает/выключает день недели; последний выбранный снять нельзя.
  RecurrenceDraft toggleWeekDay(int day) {
    final next = weekDays.contains(day) ? (List.of(weekDays)..remove(day)) : [...weekDays, day];
    if (next.isEmpty) {
      return this;
    }

    return _copy(weekDays: _sorted(next), weekDaysTouched: true);
  }

  RecurrenceDraft withWeekdaysPreset() => _copy(weekDays: _weekdays, weekDaysTouched: true);

  RecurrenceDraft withWeekendPreset() => _copy(weekDays: _weekend, weekDaysTouched: true);

  RecurrenceDraft withAllDaysPreset() =>
      _copy(weekDays: const [1, 2, 3, 4, 5, 6, 7], weekDaysTouched: true);

  // --- числа месяца ---

  RecurrenceDraft toggleMonthDay(MonthDay day) {
    final next = monthDays.contains(day) ? (List.of(monthDays)..remove(day)) : [...monthDays, day];
    if (next.isEmpty) {
      return this;
    }

    return _copy(monthDays: _sorted(next), monthDaysTouched: true);
  }

  // --- даты года ---

  /// Добавляет дату (или убирает, если уже есть; последнюю убрать нельзя).
  RecurrenceDraft toggleYearDate(YearDate date) {
    final next = yearDates.contains(date)
        ? (List.of(yearDates)..remove(date))
        : [...yearDates, date];
    if (next.isEmpty) {
      return this;
    }

    return _copy(yearDates: _sorted(next), yearDatesTouched: true);
  }

  /// Заменяет дату [from] на [to] (правка выбранной даты барабаном); дубли сливаются.
  RecurrenceDraft replaceYearDate(YearDate from, YearDate to) {
    final next = {...yearDates.where((d) => d != from), to}.toList();

    return _copy(yearDates: _sorted(next), yearDatesTouched: true);
  }

  // --- времена в день ---

  /// Меняет число раз в день. Пока времена не правили вручную — автораскладка; после правки «+»
  /// добавляет время через 2 часа после последнего, «−» убирает последнее.
  RecurrenceDraft withTimesCount(int value) {
    if (!supportsTimes) {
      return this;
    }
    final target = value.clamp(1, RecurrenceLimits.maxTimesPerDay);
    if (!timesEdited) {
      return _copy(times: _autoLayout(target));
    }
    var next = List.of(times);
    while (next.length > target) {
      next.removeLast();
    }
    while (next.length < target) {
      next = _normalizedTimes([...next, _nextFreeTime(next)]);
    }

    return _copy(times: next, timesEdited: true);
  }

  /// Меняет время с индексом [index]; совпавшие времена сливаются.
  RecurrenceDraft withTimeAt(int index, LocalTime value) {
    if (index < 0 || index >= times.length) {
      return this;
    }
    final next = List.of(times)..[index] = value;

    return _copy(times: _normalizedTimes(next), timesEdited: true);
  }

  /// Удаляет время с индексом [index]; последнее удалить нельзя.
  RecurrenceDraft removeTimeAt(int index) {
    if (times.length <= 1 || index < 0 || index >= times.length) {
      return this;
    }

    return _copy(times: List.of(times)..removeAt(index), timesEdited: true);
  }

  // --- окончание ---

  RecurrenceDraft withEnd(RecurrenceEnd value) => _copy(end: value);

  /// Число повторений в допустимых пределах.
  RecurrenceDraft withEndCount(int value) => _copy(
    end: RecurrenceEnd.afterCount(
      value.clamp(RecurrenceLimits.minEndCount, RecurrenceLimits.maxEndCount),
    ),
  );

  // --- привязка к событию ---

  /// Дата/время события изменились: нетронутые значения по умолчанию пересчитываются,
  /// настройки пользователя остаются.
  RecurrenceDraft rebase({required DateTime eventDate, String? eventTime}) {
    final time = LocalTime.tryParse(eventTime);
    final day = _day(eventDate);
    final timesNow = timesEdited
        ? (time == null ? const <LocalTime>[] : times)
        : (time == null ? const <LocalTime>[] : null);
    final rebased = _copy(
      eventDate: day,
      eventTime: time,
      clearEventTime: time == null,
      weekDays: weekDaysTouched ? null : [day.weekday],
      monthDays: monthDaysTouched ? null : [MonthDay(day.day)],
      yearDates: yearDatesTouched ? null : [YearDate(day.month, day.day)],
      times: timesNow,
    );
    if (time == null || timesEdited) {
      return rebased;
    }

    return rebased._copy(times: rebased._autoLayout(times.isEmpty ? 1 : times.length, first: time));
  }

  // --- результат ---

  /// Правило для выбранного периода (`times` — только при нескольких временах в день).
  RecurrenceModel toModel() => RecurrenceModel(
    period: period,
    interval: interval,
    weekDays: period == RecurrencePeriod.week ? weekDays : const [],
    monthDays: period == RecurrencePeriod.month ? monthDays : const [],
    yearDates: period == RecurrencePeriod.year ? yearDates : const [],
    times: period == RecurrencePeriod.day && times.length > 1 ? times : const [],
    end: end,
  );

  /// Время события после сохранения: первое из времён в день (если оно одно или несколько),
  /// иначе прежнее [eventTime].
  String? get resultingEventTime => period == RecurrencePeriod.day && times.isNotEmpty
      ? times.first.format()
      : eventTime?.format();

  /// Ошибка окончания «до даты» (раньше события или первого повторения) либо `null`.
  RecurrenceEndError? get endError => RecurrenceCalculator.endError(toModel(), eventDate);

  /// Число повторений вне допустимых пределов.
  bool get hasInvalidEndCount {
    final current = end;

    return current is RecurrenceEnd$AfterCount &&
        (current.count < RecurrenceLimits.minEndCount ||
            current.count > RecurrenceLimits.maxEndCount);
  }

  bool get canSave => endError == null && !hasInvalidEndCount;

  // --- внутреннее ---

  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

  static bool _same(List<int> a, List<int> b) => a.length == b.length && b.every(a.contains);

  static List<T> _sorted<T>(Iterable<T> values) => values.toSet().toList()..sort();

  static List<LocalTime> _normalizedTimes(Iterable<LocalTime> values) => _sorted(values);

  /// Следующее свободное время: через 2 часа после последнего, иначе первое свободное сверху вниз.
  static LocalTime _nextFreeTime(List<LocalTime> existing) {
    if (existing.isEmpty) {
      return const LocalTime(8, 0);
    }
    final minutes = existing.map((t) => t.totalMinutes).toSet();
    final afterLast = existing.last.totalMinutes + 120;
    if (afterLast < 24 * 60 && !minutes.contains(afterLast)) {
      return LocalTime(afterLast ~/ 60, afterLast % 60);
    }
    for (var m = 0; m < 24 * 60; m += 30) {
      if (!minutes.contains(m)) {
        return LocalTime(m ~/ 60, m % 60);
      }
    }

    return existing.last;
  }

  /// Раскладка [count] времён по дню; для одного — время события.
  List<LocalTime> _autoLayout(int count, {LocalTime? first}) {
    final anchor = first ?? eventTime;
    if (anchor == null) {
      return const [];
    }
    const layouts = {
      2: [LocalTime(9, 0), LocalTime(21, 0)],
      3: [LocalTime(8, 0), LocalTime(14, 0), LocalTime(20, 0)],
      4: [LocalTime(8, 0), LocalTime(12, 0), LocalTime(16, 0), LocalTime(20, 0)],
      5: [LocalTime(8, 0), LocalTime(11, 0), LocalTime(14, 0), LocalTime(17, 0), LocalTime(20, 0)],
      6: [
        LocalTime(7, 0),
        LocalTime(10, 0),
        LocalTime(13, 0),
        LocalTime(16, 0),
        LocalTime(19, 0),
        LocalTime(22, 0),
      ],
    };

    return count <= 1 ? [anchor] : layouts[count]!;
  }

  RecurrenceDraft _copy({
    RecurrencePeriod? period,
    Map<RecurrencePeriod, int>? intervals,
    List<int>? weekDays,
    List<MonthDay>? monthDays,
    List<YearDate>? yearDates,
    List<LocalTime>? times,
    RecurrenceEnd? end,
    DateTime? eventDate,
    LocalTime? eventTime,
    bool clearEventTime = false,
    bool? weekDaysTouched,
    bool? monthDaysTouched,
    bool? yearDatesTouched,
    bool? timesEdited,
  }) => RecurrenceDraft._(
    period: period ?? this.period,
    intervals: intervals ?? this.intervals,
    weekDays: weekDays ?? this.weekDays,
    monthDays: monthDays ?? this.monthDays,
    yearDates: yearDates ?? this.yearDates,
    times: times ?? this.times,
    end: end ?? this.end,
    eventDate: eventDate ?? this.eventDate,
    eventTime: clearEventTime ? null : (eventTime ?? this.eventTime),
    weekDaysTouched: weekDaysTouched ?? this.weekDaysTouched,
    monthDaysTouched: monthDaysTouched ?? this.monthDaysTouched,
    yearDatesTouched: yearDatesTouched ?? this.yearDatesTouched,
    timesEdited: timesEdited ?? this.timesEdited,
  );

  @override
  List<Object?> get props => [
    period,
    intervals,
    weekDays,
    monthDays,
    yearDates,
    times,
    end,
    eventDate,
    eventTime,
    weekDaysTouched,
    monthDaysTouched,
    yearDatesTouched,
    timesEdited,
  ];
}
