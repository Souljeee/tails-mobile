import 'package:equatable/equatable.dart';

/// Диапазон дат, для которого загружено расписание.
///
/// Окно строится вокруг выбранного месяца и сдвигается, когда пользователь
/// листает календарь за его пределы.
class ScheduleWindow extends Equatable {
  const ScheduleWindow({required this.start, required this.end});

  /// Окно в [halfSpanDays] дней в обе стороны от [center].
  factory ScheduleWindow.around(DateTime center, {int halfSpanDays = defaultHalfSpanDays}) {
    final day = DateTime(center.year, center.month, center.day);

    return ScheduleWindow(
      start: day.subtract(Duration(days: halfSpanDays)),
      end: day.add(Duration(days: halfSpanDays)),
    );
  }

  static const int defaultHalfSpanDays = 180;

  final DateTime start;
  final DateTime end;

  /// Входит ли месяц [month] (любой день месяца) в окно целиком.
  bool coversMonth(DateTime month) {
    final first = DateTime(month.year, month.month);
    final last = DateTime(month.year, month.month + 1, 0);

    return !first.isBefore(start) && !last.isAfter(end);
  }

  @override
  List<Object?> get props => [start, end];
}
