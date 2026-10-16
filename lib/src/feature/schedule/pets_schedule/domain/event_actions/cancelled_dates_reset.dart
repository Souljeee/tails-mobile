import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_calculator.dart';

/// Какие из уже отменённых дат пропадут после смены расписания (подсказка в форме, п. 8.3 ТЗ).
///
/// Сервер при сохранении сбрасывает отмены тех дат, которых нет в новом расписании; остальные
/// сохраняет. Здесь та же проверка на клиенте: `cancelledDates` приходят из `series_stats`.
abstract final class CancelledDatesReset {
  /// Отменённые даты, которых не будет в расписании с началом [start] и правилом [rule].
  /// [rule] = `null` — событие станет одиночным и останется одна дата [start].
  static List<DateTime> lost({
    required List<DateTime> cancelledDates,
    required DateTime start,
    required RecurrenceModel? rule,
  }) {
    if (cancelledDates.isEmpty) {
      return const [];
    }

    final days = cancelledDates.map(_day).toSet().toList()..sort();
    final first = days.first;
    final last = days.last;
    final from = first.isBefore(_day(start)) ? first : _day(start);

    final Set<DateTime> kept = rule == null
        ? {_day(start)}
        : RecurrenceCalculator.occurrencesInWindow(
            rule,
            start,
            from: from,
            to: last,
            until: RecurrenceCalculator.until(rule, start),
          ).toSet();

    return days.where((day) => !kept.contains(day)).toList();
  }

  /// Хотя бы одна отмена сбросится.
  static bool willReset({
    required List<DateTime> cancelledDates,
    required DateTime start,
    required RecurrenceModel? rule,
  }) => lost(cancelledDates: cancelledDates, start: start, rule: rule).isNotEmpty;

  static DateTime _day(DateTime value) => DateTime(value.year, value.month, value.day);
}
