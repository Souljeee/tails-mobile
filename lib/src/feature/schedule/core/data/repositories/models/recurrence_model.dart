import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';

/// Правило повторения события.
///
/// Заполняются только поля выбранного [period]; остальные пусты. Семантика вхождений —
/// в `recurrence/domain/recurrence_calculator.dart` (общая с сервером, см. тестовые векторы).
/// Все времена и даты — локальные.
class RecurrenceModel extends Equatable {
  const RecurrenceModel({
    required this.period,
    this.interval = 1,
    this.weekDays = const [],
    this.monthDays = const [],
    this.yearDates = const [],
    this.times = const [],
    this.end = const RecurrenceEnd.never(),
  });

  final RecurrencePeriod period;

  /// «Каждые N дней/недель/месяцев/лет».
  final int interval;

  /// Дни недели 1–7 (Пн = 1), по возрастанию.
  final List<int> weekDays;

  /// Числа месяца по возрастанию, «последний день» в конце.
  final List<MonthDay> monthDays;

  /// Даты года без года, по возрастанию.
  final List<YearDate> yearDates;

  /// Несколько времён в день (только [RecurrencePeriod.day], ≥ 2 значений, по возрастанию);
  /// при одном времени пусто — оно хранится во времени события.
  final List<LocalTime> times;

  final RecurrenceEnd end;

  @override
  List<Object?> get props => [period, interval, weekDays, monthDays, yearDates, times, end];
}
