import 'package:equatable/equatable.dart';

/// Период повторения (значения API — в [apiValue]).
enum RecurrencePeriod {
  day('daily'),
  week('weekly'),
  month('monthly'),
  year('yearly'),

  /// Значение, которого приложение не знает (новый период на сервере): событие не теряется,
  /// но редактировать его правило нельзя.
  unknown('');

  const RecurrencePeriod(this.apiValue);

  final String apiValue;

  static RecurrencePeriod fromApi(String? value) => RecurrencePeriod.values.firstWhere(
    (period) => period != RecurrencePeriod.unknown && period.apiValue == value,
    orElse: () => RecurrencePeriod.unknown,
  );
}

/// Число месяца: 1–31 либо [MonthDay.last] («последний день»; в API — `-1`).
class MonthDay extends Equatable implements Comparable<MonthDay> {
  const MonthDay(this.value)
    : assert(value == -1 || (value >= 1 && value <= 31), 'Число месяца: 1–31 или -1');

  static const last = MonthDay(-1);

  /// 1–31 или `-1`.
  final int value;

  bool get isLast => value == -1;

  /// «Последний день» всегда в конце списка.
  @override
  int compareTo(MonthDay other) {
    final a = isLast ? 99 : value;
    final b = other.isLast ? 99 : other.value;

    return a.compareTo(b);
  }

  @override
  List<Object?> get props => [value];
}

/// Дата в году без года: месяц (1–12) и день.
class YearDate extends Equatable implements Comparable<YearDate> {
  const YearDate(this.month, this.day);

  final int month;
  final int day;

  bool get isFeb29 => month == 2 && day == 29;

  @override
  int compareTo(YearDate other) {
    final byMonth = month.compareTo(other.month);

    return byMonth != 0 ? byMonth : day.compareTo(other.day);
  }

  @override
  List<Object?> get props => [month, day];
}

/// Локальное время суток с точностью до минуты.
class LocalTime extends Equatable implements Comparable<LocalTime> {
  const LocalTime(this.hour, this.minute);

  /// Разбирает `HH:mm` (секунды игнорируются); `null`, если строка не время.
  static LocalTime? tryParse(String? value) {
    final text = value?.trim();
    if (text == null || text.length < 5) {
      return null;
    }

    final hour = int.tryParse(text.substring(0, 2));
    final minute = int.tryParse(text.substring(3, 5));
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }

    return LocalTime(hour, minute);
  }

  final int hour;
  final int minute;

  int get totalMinutes => hour * 60 + minute;

  /// `HH:mm`.
  String format() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalTime other) => totalMinutes.compareTo(other.totalMinutes);

  @override
  List<Object?> get props => [hour, minute];
}

/// Окончание повторения.
sealed class RecurrenceEnd extends Equatable {
  const RecurrenceEnd();

  const factory RecurrenceEnd.never() = RecurrenceEnd$Never;

  /// До даты включительно.
  const factory RecurrenceEnd.until(DateTime date) = RecurrenceEnd$Until;

  /// После [count] повторений (считаются дни-вхождения, не слоты времени).
  const factory RecurrenceEnd.afterCount(int count) = RecurrenceEnd$AfterCount;
}

final class RecurrenceEnd$Never extends RecurrenceEnd {
  const RecurrenceEnd$Never();

  @override
  List<Object?> get props => const [];
}

final class RecurrenceEnd$Until extends RecurrenceEnd {
  const RecurrenceEnd$Until(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

final class RecurrenceEnd$AfterCount extends RecurrenceEnd {
  const RecurrenceEnd$AfterCount(this.count);

  final int count;

  @override
  List<Object?> get props => [count];
}
