import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';

/// Какая нижняя панель с барабаном открыта на странице «Повторение» (вместо «Сохранить»).
sealed class RecurrencePanel extends Equatable {
  const RecurrencePanel();

  /// Барабан времени [index]-й плитки «Время N».
  const factory RecurrencePanel.time(int index) = RecurrencePanel$Time;

  /// Дата года: [date] — правка существующей, `null` — «Новая дата».
  const factory RecurrencePanel.yearDate(YearDate? date) = RecurrencePanel$YearDate;

  /// Дата окончания «до определённой даты».
  const factory RecurrencePanel.endDate() = RecurrencePanel$EndDate;
}

final class RecurrencePanel$Time extends RecurrencePanel {
  const RecurrencePanel$Time(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

final class RecurrencePanel$YearDate extends RecurrencePanel {
  const RecurrencePanel$YearDate(this.date);

  final YearDate? date;

  @override
  List<Object?> get props => [date];
}

final class RecurrencePanel$EndDate extends RecurrencePanel {
  const RecurrencePanel$EndDate();

  @override
  List<Object?> get props => const [];
}
