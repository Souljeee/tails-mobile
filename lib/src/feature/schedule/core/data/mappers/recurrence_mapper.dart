import 'package:intl/intl.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/recurrence_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/utils/event_time_converter.dart';

final _dateFormat = DateFormat('yyyy-MM-dd');

/// Правило из ответа API. `offsetMinutes` — `timezone_offset` события: по нему времена `times`
/// из UTC переводятся в локальные.
extension RecurrenceDtoMapper on RecurrenceDto {
  RecurrenceModel toModel({required int offsetMinutes}) {
    final period = RecurrencePeriod.fromApi(frequency);

    return RecurrenceModel(
      period: period,
      interval: interval < 1 ? 1 : interval,
      weekDays: _sortedUnique(weekDays ?? const []),
      monthDays: _sortedUnique(
        (monthDays ?? const []).where((d) => d == -1 || (d >= 1 && d <= 31)).map(MonthDay.new),
      ),
      yearDates: _sortedUnique(
        (yearDates ?? const []).map((date) => YearDate(date.month, date.day)),
      ),
      times: _sortedUnique(
        (times ?? const [])
            .map(
              (value) => LocalTime.tryParse(
                EventTimeConverter.utcToLocal(value, offsetMinutes: offsetMinutes),
              ),
            )
            .whereType<LocalTime>(),
      ),
      end: _endOf(),
    );
  }

  RecurrenceEnd _endOf() {
    final date = endDate == null ? null : DateTime.tryParse(endDate!);
    if (date != null) {
      return RecurrenceEnd.until(DateTime(date.year, date.month, date.day));
    }
    final count = endCount;
    if (count != null && count > 0) {
      return RecurrenceEnd.afterCount(count);
    }

    return const RecurrenceEnd.never();
  }
}

/// Правило для запроса. Времена `times` переводятся из локальных в UTC по `offsetMinutes`;
/// поля, не относящиеся к периоду, не отправляются.
extension RecurrenceModelMapper on RecurrenceModel {
  RecurrenceDto toDto({required int offsetMinutes}) {
    final isMulti = period == RecurrencePeriod.day && times.length > 1;

    return RecurrenceDto(
      frequency: period.apiValue,
      interval: interval,
      weekDays: period == RecurrencePeriod.week ? weekDays : null,
      monthDays: period == RecurrencePeriod.month ? monthDays.map((d) => d.value).toList() : null,
      yearDates: period == RecurrencePeriod.year
          ? yearDates.map((d) => YearDateDto(month: d.month, day: d.day)).toList()
          : null,
      times: isMulti
          ? times
                .map((t) => EventTimeConverter.localToUtc(t.format(), offsetMinutes: offsetMinutes))
                .whereType<String>()
                .toList()
          : null,
      endType: switch (end) {
        RecurrenceEnd$Never() => 'never',
        RecurrenceEnd$Until() => 'date',
        RecurrenceEnd$AfterCount() => 'count',
      },
      endDate: switch (end) {
        RecurrenceEnd$Until(:final date) => _dateFormat.format(date),
        _ => null,
      },
      endCount: switch (end) {
        RecurrenceEnd$AfterCount(:final count) => count,
        _ => null,
      },
    );
  }
}

List<T> _sortedUnique<T>(Iterable<T> values) => values.toSet().toList()..sort();
