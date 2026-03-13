extension DateTimeExtension on DateTime {
  DateTime get monthStart => DateTime(year, month);

  DateTime addMonth(int count) {
    return DateTime(year, month + count, day);
  }

  DateTime subtractMonth(int count) {
    return DateTime(year, month - count, day);
  }

  DateTime subtractYear(int count) {
    return DateTime(year - count, month, day);
  }

  DateTime addYear(int count) {
    return DateTime(year + count, month, day);
  }

  bool isSameDate(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }

  bool get isToday {
    return isSameDate(DateTime.now());
  }

  DateTime roundToSeconds() {
    return DateTime(year, month, day, hour, minute, second);
  }

  bool isInRange({
    required DateTime rangeStart,
    required DateTime rangeFinish,
  }) {
    return isAfter(rangeStart.subtract(const Duration(days: 1))) &&
        isBefore(rangeFinish.add(const Duration(days: 1)));
  }

  DateTime get withoutTime => DateTime(year, month, day);
}