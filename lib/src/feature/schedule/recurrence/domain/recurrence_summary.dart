import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_calculator.dart';

/// Итог правила словами: [title] — «что» («По будням»), [subtitle] — «как часто» и детали
/// («3 раза в неделю · в 17:05 · до 31.12.2026»).
class RecurrenceSummary extends Equatable {
  const RecurrenceSummary({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  List<Object?> get props => [title, subtitle];
}

/// Строит [RecurrenceSummary] из правила. Все тексты — через локализацию (ICU-плюралы).
class RecurrenceSummaryBuilder {
  const RecurrenceSummaryBuilder(this._l10n);

  final AppLocalizations _l10n;

  static final _dateFormat = DateFormat('dd.MM.yyyy');

  /// [start] — дата события (нужна для вычисления даты последнего повторения при «после N»).
  /// [eventTime] — локальное время события `HH:mm` (`null` — «весь день»); при нескольких
  /// временах в день берутся они.
  RecurrenceSummary build(RecurrenceModel rule, {required DateTime start, String? eventTime}) {
    // «Каждый день» с несколькими временами: заголовок — «3 раза в день», во второй строке времена.
    if (_isDailyWithSlots(rule) && rule.interval <= 1) {
      return RecurrenceSummary(
        title: _l10n.recurrenceTimesPerDay(rule.times.length),
        subtitle: [
          rule.times.map((t) => t.format()).join(' · '),
          ..._endParts(rule, start),
        ].join(' · '),
      );
    }

    return RecurrenceSummary(
      title: _title(rule),
      subtitle: [
        ..._countParts(rule),
        ..._timeParts(rule, eventTime),
        ..._endParts(rule, start),
      ].join(' · '),
    );
  }

  bool _isDailyWithSlots(RecurrenceModel rule) =>
      rule.period == RecurrencePeriod.day && rule.times.length > 1;

  String _title(RecurrenceModel rule) {
    switch (rule.period) {
      case RecurrencePeriod.day:
        return switch (rule.interval) {
          <= 1 => _l10n.recurrenceEveryDay,
          2 => _l10n.recurrenceEveryOtherDay,
          final n => _l10n.recurrenceEveryNDays(n),
        };
      case RecurrencePeriod.week:
        return _weekTitle(rule);
      case RecurrencePeriod.month:
        return _monthTitle(rule);
      case RecurrencePeriod.year:
        return _yearTitle(rule);
      case RecurrencePeriod.unknown:
        return '';
    }
  }

  String _weekTitle(RecurrenceModel rule) {
    final days = rule.weekDays;
    if (rule.interval <= 1) {
      if (days.length == 7) {
        return _l10n.recurrenceEveryDay;
      }
      if (_sameDays(days, const [1, 2, 3, 4, 5])) {
        return _l10n.recurrenceWeekdays;
      }
      if (_sameDays(days, const [6, 7])) {
        return _l10n.recurrenceWeekends;
      }
      if (days.length == 1) {
        return _l10n.recurrenceEveryWeekday('${days.single}');
      }

      return _l10n.recurrenceOnWeekdays(_join(days.map(_weekdayDative)));
    }

    return _l10n.recurrenceEveryNWeeksOn(rule.interval, _join(days.map(_weekdayDative)));
  }

  String _monthTitle(RecurrenceModel rule) {
    final every = rule.interval <= 1
        ? _l10n.recurrenceMonthEvery
        : _l10n.recurrenceMonthEveryN(rule.interval);
    final numbers = _join(rule.monthDays.where((d) => !d.isLast).map((d) => '${d.value}'));
    final hasLast = rule.monthDays.any((d) => d.isLast);

    if (numbers.isEmpty) {
      return _l10n.recurrenceMonthLast(every);
    }

    return hasLast
        ? _l10n.recurrenceMonthNumbersAndLast(numbers, every)
        : _l10n.recurrenceMonthNumbers(numbers, every);
  }

  String _yearTitle(RecurrenceModel rule) {
    final dates = _join(
      rule.yearDates.map(
        (d) => _l10n.recurrenceDayMonth(d.day, _l10n.recurrenceMonthGenitive('${d.month}')),
      ),
    );

    return rule.interval <= 1
        ? _l10n.recurrenceYearEvery(dates)
        : _l10n.recurrenceYearEveryN(dates, rule.interval);
  }

  /// «3 раза в неделю», «раз в 2 года», «2 раза за 2 недели»; для дней и неизвестного периода —
  /// только при нескольких временах в день.
  List<String> _countParts(RecurrenceModel rule) {
    final interval = rule.interval < 1 ? 1 : rule.interval;
    switch (rule.period) {
      case RecurrencePeriod.day:
        return rule.times.length > 1 ? [_l10n.recurrenceTimesPerDay(rule.times.length)] : const [];
      case RecurrencePeriod.week:
        final count = rule.weekDays.length;
        if (interval == 1) {
          return [
            if (count == 1) _l10n.recurrenceOncePerWeek else _l10n.recurrenceTimesPerWeek(count),
          ];
        }

        return [_inUnits(count, _l10n.recurrenceUnitWeeks(interval))];
      case RecurrencePeriod.month:
        final count = rule.monthDays.length;
        if (interval == 1) {
          return [
            if (count == 1) _l10n.recurrenceOncePerMonth else _l10n.recurrenceTimesPerMonth(count),
          ];
        }

        return [_inUnits(count, _l10n.recurrenceUnitMonths(interval))];
      case RecurrencePeriod.year:
        final count = rule.yearDates.length;
        if (interval == 1) {
          return [
            if (count == 1) _l10n.recurrenceOncePerYear else _l10n.recurrenceTimesPerYear(count),
          ];
        }

        return [_inUnits(count, _l10n.recurrenceUnitYears(interval))];
      case RecurrencePeriod.unknown:
        return const [];
    }
  }

  String _inUnits(int count, String unit) =>
      count == 1 ? _l10n.recurrenceOnceInUnits(unit) : _l10n.recurrenceTimesInUnits(count, unit);

  List<String> _timeParts(RecurrenceModel rule, String? eventTime) {
    if (rule.period == RecurrencePeriod.day && rule.times.length > 1) {
      return [_l10n.recurrenceAtTime(_join(rule.times.map((t) => t.format())))];
    }
    final time = LocalTime.tryParse(eventTime);

    return time == null ? const [] : [_l10n.recurrenceAtTime(time.format())];
  }

  /// «до 31.12.2026»; для «после N повторений» ещё и вычисленная дата последнего повторения.
  List<String> _endParts(RecurrenceModel rule, DateTime start) {
    switch (rule.end) {
      case RecurrenceEnd$Never():
        return const [];
      case RecurrenceEnd$Until(:final date):
        return [_l10n.recurrenceEndUntil(_dateFormat.format(date))];
      case RecurrenceEnd$AfterCount(:final count):
        final last = RecurrenceCalculator.until(rule, start);

        return [
          _l10n.recurrenceEndAfter(count),
          if (last != null && !last.isAfter(RecurrenceCalculator.horizon))
            _l10n.recurrenceEndUntil(_dateFormat.format(last)),
        ];
    }
  }

  String _weekdayDative(int weekday) => _l10n.recurrenceWeekdayDative('$weekday');

  /// «а, б и в».
  String _join(Iterable<String> items) {
    final list = items.toList();
    if (list.length <= 1) {
      return list.join();
    }

    return '${list.sublist(0, list.length - 1).join(', ')} ${_l10n.recurrenceAnd} ${list.last}';
  }

  bool _sameDays(List<int> days, List<int> expected) =>
      days.length == expected.length && expected.every(days.contains);
}
