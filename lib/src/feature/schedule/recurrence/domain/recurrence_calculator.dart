import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';

/// Ошибка окончания повторения (тексты сообщений показывает UI).
sealed class RecurrenceEndError {
  const RecurrenceEndError();
}

/// Дата окончания раньше даты события.
final class RecurrenceEndError$BeforeStart extends RecurrenceEndError {
  const RecurrenceEndError$BeforeStart();
}

/// Дата окончания раньше первого повторения ([first]).
final class RecurrenceEndError$BeforeFirst extends RecurrenceEndError {
  const RecurrenceEndError$BeforeFirst(this.first);

  final DateTime first;
}

/// Вхождения правила повторения — порт `tracker/recurrence.py` бэкенда.
///
/// Семантика общая с сервером и проверяется общим файлом `recurrence_vectors.json`:
///
/// 1. Первое вхождение — первая дата ≥ даты события, подходящая под выбор дней/чисел/дат
///    **без учёта интервала** (для дней — сама дата события).
/// 2. Якорный период — неделя (с понедельника) / месяц / год, содержащий первое вхождение;
///    допустимы периоды `якорь + k × interval`. Для года с 29.02 и `interval > 1` якорный год —
///    ближайший високосный не раньше года первого вхождения.
/// 3. Месяц: число `d` → `min(d, последний день месяца)`, «последний день» — конец месяца,
///    совпавшие даты сливаются. Год: 29.02 в невисокосный год → 28.02.
/// 4. Вхождения не позже [until]: даты окончания либо даты N-го вхождения-дня.
///
/// Все даты — «настенные» (локальные, без времени), хранятся как `DateTime(y, m, d)`.
abstract final class RecurrenceCalculator {
  /// Верхний горизонт расчёта (как на сервере): защита от бесконечных переборов.
  static final DateTime horizon = DateTime(2100, 12, 31);

  /// Первое вхождение либо `null`, если правило не задаёт ни одной даты.
  static DateTime? firstOccurrence(RecurrenceModel rule, DateTime start) =>
      _anchor(rule, _day(start))?.first;

  /// Все вхождения по возрастанию, начиная с первого (лениво; до [horizon]).
  static Iterable<DateTime> occurrences(RecurrenceModel rule, DateTime start) =>
      _iterate(rule, _day(start), null);

  /// Вхождения в окне `[from, to]` с учётом [until] (границы включительно).
  static List<DateTime> occurrencesInWindow(
    RecurrenceModel rule,
    DateTime start, {
    required DateTime from,
    required DateTime to,
    DateTime? until,
  }) {
    final limit = until != null && until.isBefore(to) ? _day(until) : _day(to);
    final result = <DateTime>[];
    for (final day in _iterate(rule, _day(start), _day(from))) {
      if (day.isAfter(limit)) {
        break;
      }
      result.add(day);
    }

    return result;
  }

  /// Ближайшие [count] вхождений от даты события (с учётом окончания) — для подсказки в форме.
  static List<DateTime> nextOccurrences(RecurrenceModel rule, DateTime start, {int count = 3}) {
    final limit = until(rule, start);
    final result = <DateTime>[];
    for (final day in _iterate(rule, _day(start), null)) {
      if (limit != null && day.isAfter(limit)) {
        break;
      }
      result.add(day);
      if (result.length >= count) {
        break;
      }
    }

    return result;
  }

  /// Эффективная дата окончания: дата «до», дата N-го вхождения-дня или `null` («без окончания»).
  static DateTime? until(RecurrenceModel rule, DateTime start) {
    switch (rule.end) {
      case RecurrenceEnd$Until(:final date):
        return _day(date);
      case RecurrenceEnd$AfterCount(:final count):
        var seen = 0;
        for (final day in _iterate(rule, _day(start), null)) {
          if (day.isAfter(horizon)) {
            return horizon;
          }
          seen++;
          if (seen >= count) {
            return day;
          }
        }

        return horizon;
      case RecurrenceEnd$Never():
        return null;
    }
  }

  /// Проверка окончания «до даты» относительно даты события и первого повторения.
  static RecurrenceEndError? endError(RecurrenceModel rule, DateTime start) {
    final end = rule.end;
    if (end is! RecurrenceEnd$Until) {
      return null;
    }
    final endDay = _day(end.date);
    if (endDay.isBefore(_day(start))) {
      return const RecurrenceEndError$BeforeStart();
    }
    final first = firstOccurrence(rule, start);
    if (first != null && endDay.isBefore(first)) {
      return RecurrenceEndError$BeforeFirst(first);
    }

    return null;
  }

  // --- внутреннее ---

  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);

  static int _lastDayOfMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  static bool _isLeap(int year) => (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static DateTime _monday(DateTime day) =>
      DateTime(day.year, day.month, day.day - (day.weekday - 1));

  static List<DateTime> _monthDates(int year, int month, List<MonthDay> monthDays) {
    final last = _lastDayOfMonth(year, month);
    final days = {
      for (final d in monthDays)
        DateTime(year, month, d.isLast ? last : (d.value < last ? d.value : last)),
    }.toList()..sort();

    return days;
  }

  static List<DateTime> _yearDatesIn(int year, List<YearDate> yearDates) {
    final days = {
      for (final d in yearDates)
        DateTime(
          year,
          d.month,
          d.day < _lastDayOfMonth(year, d.month) ? d.day : _lastDayOfMonth(year, d.month),
        ),
    }.toList()..sort();

    return days;
  }

  /// `(первое вхождение, якорь)`; якорь — дата начала периода (для года — 1 января якорного года).
  static ({DateTime first, DateTime anchor})? _anchor(RecurrenceModel rule, DateTime start) {
    switch (rule.period) {
      case RecurrencePeriod.day:
        return (first: start, anchor: start);
      case RecurrencePeriod.week:
        if (rule.weekDays.isEmpty) {
          return null;
        }
        for (var i = 0; i < 7; i++) {
          final day = DateTime(start.year, start.month, start.day + i);
          if (rule.weekDays.contains(day.weekday)) {
            return (first: day, anchor: _monday(day));
          }
        }

        return null;
      case RecurrencePeriod.month:
        if (rule.monthDays.isEmpty) {
          return null;
        }
        var year = start.year;
        var month = start.month;
        for (var i = 0; i < 3; i++) {
          final candidates = _monthDates(
            year,
            month,
            rule.monthDays,
          ).where((d) => !d.isBefore(start));
          if (candidates.isNotEmpty) {
            return (first: candidates.first, anchor: candidates.first);
          }
          if (month == 12) {
            year++;
            month = 1;
          } else {
            month++;
          }
        }

        return null;
      case RecurrencePeriod.year:
        if (rule.yearDates.isEmpty) {
          return null;
        }
        final hasFeb29 = rule.yearDates.any((d) => d.isFeb29);
        for (var year = start.year; year < start.year + 3; year++) {
          final candidates = _yearDatesIn(year, rule.yearDates).where((d) => !d.isBefore(start));
          if (candidates.isEmpty) {
            continue;
          }
          var anchorYear = candidates.first.year;
          if (hasFeb29 && rule.interval > 1) {
            while (!_isLeap(anchorYear)) {
              anchorYear++;
            }
            final first = _yearDatesIn(
              anchorYear,
              rule.yearDates,
            ).firstWhere((d) => !d.isBefore(start));

            return (first: first, anchor: DateTime(anchorYear));
          }

          return (first: candidates.first, anchor: DateTime(anchorYear));
        }

        return null;
      case RecurrencePeriod.unknown:
        return null;
    }
  }

  static List<DateTime> _periodDates(RecurrenceModel rule, DateTime anchor, int k) {
    final step = rule.interval < 1 ? 1 : rule.interval;
    switch (rule.period) {
      case RecurrencePeriod.day:
        return [DateTime(anchor.year, anchor.month, anchor.day + k * step)];
      case RecurrencePeriod.week:
        final week = DateTime(anchor.year, anchor.month, anchor.day + 7 * step * k);

        return [for (final wd in rule.weekDays) DateTime(week.year, week.month, week.day + wd - 1)];
      case RecurrencePeriod.month:
        final index = anchor.year * 12 + anchor.month - 1 + k * step;

        return _monthDates(index ~/ 12, index % 12 + 1, rule.monthDays);
      case RecurrencePeriod.year:
        return _yearDatesIn(anchor.year + k * step, rule.yearDates);
      case RecurrencePeriod.unknown:
        return const [];
    }
  }

  /// Индекс периода, с которого стоит начинать, чтобы не перебирать всё от старта.
  static int _firstPeriodIndex(RecurrenceModel rule, DateTime anchor, DateTime? from) {
    if (from == null) {
      return 0;
    }
    final step = rule.interval < 1 ? 1 : rule.interval;
    final int index;
    switch (rule.period) {
      case RecurrencePeriod.day:
        index = _daysBetween(anchor, from) ~/ step;
      case RecurrencePeriod.week:
        index = _daysBetween(anchor, from) ~/ (7 * step);
      case RecurrencePeriod.month:
        index = ((from.year * 12 + from.month - 1) - (anchor.year * 12 + anchor.month - 1)) ~/ step;
      case RecurrencePeriod.year:
        index = (from.year - anchor.year) ~/ step;
      case RecurrencePeriod.unknown:
        index = 0;
    }

    // Целочисленное деление в Dart округляет к нулю, а для отрицательных нужно «вниз» — берём 0.
    return index < 0 ? 0 : index;
  }

  static int _daysBetween(DateTime a, DateTime b) =>
      DateTime.utc(b.year, b.month, b.day).difference(DateTime.utc(a.year, a.month, a.day)).inDays;

  static Iterable<DateTime> _iterate(RecurrenceModel rule, DateTime start, DateTime? from) sync* {
    final found = _anchor(rule, start);
    if (found == null) {
      return;
    }
    var k = _firstPeriodIndex(rule, found.anchor, from);
    while (true) {
      final dates = _periodDates(rule, found.anchor, k);
      if (dates.isNotEmpty && dates.first.isAfter(horizon)) {
        return;
      }
      for (final day in dates) {
        if (!day.isBefore(found.first) && (from == null || !day.isBefore(from))) {
          yield day;
        }
      }
      k++;
    }
  }
}
