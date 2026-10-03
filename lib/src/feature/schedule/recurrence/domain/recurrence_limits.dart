import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';

/// Границы значений правила повторения (совпадают с проверками бэкенда, ответ 400 при выходе).
abstract final class RecurrenceLimits {
  static const maxTimesPerDay = 6;
  static const minEndCount = 2;
  static const maxEndCount = 999;

  /// Наибольший интервал «каждые N …» для периода.
  static int maxInterval(RecurrencePeriod period) => switch (period) {
    RecurrencePeriod.day => 30,
    RecurrencePeriod.week => 12,
    RecurrencePeriod.month => 12,
    RecurrencePeriod.year => 10,
    RecurrencePeriod.unknown => 1,
  };
}
