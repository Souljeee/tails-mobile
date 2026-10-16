part of 'schedule_bloc.dart';

typedef ScheduleEventMatch<T, S extends ScheduleEvent> = T Function(S event);

sealed class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  const factory ScheduleEvent.fetchRequested({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
    bool silent,
    Completer<void>? completer,
  }) = ScheduleEvent$FetchRequested;

  const factory ScheduleEvent.loadMoreRequested({
    required DateTime startDate,
    required DateTime endDate,
    int? petId,
  }) = ScheduleEvent$LoadMoreRequested;

  const factory ScheduleEvent.markDoneRequested({
    required String eventId,
    required DateTime date,
    required bool value,
    String? time,
  }) = ScheduleEvent$MarkDoneRequested;

  /// Применить отмену или возврат к уже загруженным данным (без запроса). [dropFollowing]
  /// дополнительно убирает вхождения серии позже даты [ref] (отмена «и все следующие»).
  const factory ScheduleEvent.occurrenceCancelledChanged({
    required EventOccurrenceRef ref,
    required bool cancelled,
    bool dropFollowing,
  }) = ScheduleEvent$OccurrenceCancelledChanged;

  /// Заменить вхождение моделью с сервера (то же событие, дата и слот времени).
  const factory ScheduleEvent.occurrenceReplaced({required ScheduleEventModel occurrence}) =
      ScheduleEvent$OccurrenceReplaced;

  /// Тихо перезагрузить последнее окно: после отката отмены серии и редактирования с разделением
  /// серии, когда идентификаторы будущих вхождений поменялись.
  const factory ScheduleEvent.refreshRequested({Completer<void>? completer}) =
      ScheduleEvent$RefreshRequested;

  T map<T>({
    required ScheduleEventMatch<T, ScheduleEvent$FetchRequested> fetchRequested,
    required ScheduleEventMatch<T, ScheduleEvent$LoadMoreRequested> loadMoreRequested,
    required ScheduleEventMatch<T, ScheduleEvent$MarkDoneRequested> markDoneRequested,
    required ScheduleEventMatch<T, ScheduleEvent$OccurrenceCancelledChanged>
    occurrenceCancelledChanged,
    required ScheduleEventMatch<T, ScheduleEvent$OccurrenceReplaced> occurrenceReplaced,
    required ScheduleEventMatch<T, ScheduleEvent$RefreshRequested> refreshRequested,
  }) => switch (this) {
    final ScheduleEvent$FetchRequested event => fetchRequested(event),
    final ScheduleEvent$LoadMoreRequested event => loadMoreRequested(event),
    final ScheduleEvent$MarkDoneRequested event => markDoneRequested(event),
    final ScheduleEvent$OccurrenceCancelledChanged event => occurrenceCancelledChanged(event),
    final ScheduleEvent$OccurrenceReplaced event => occurrenceReplaced(event),
    final ScheduleEvent$RefreshRequested event => refreshRequested(event),
  };
}

final class ScheduleEvent$FetchRequested extends ScheduleEvent {
  final DateTime startDate;
  final DateTime endDate;
  final int? petId;

  /// Тихое обновление: уже показанные данные не заменяются индикатором загрузки.
  final bool silent;

  /// Завершается, когда обработка закончена (для pull-to-refresh).
  final Completer<void>? completer;

  const ScheduleEvent$FetchRequested({
    required this.startDate,
    required this.endDate,
    this.petId,
    this.silent = false,
    this.completer,
  });

  @override
  List<Object?> get props => [startDate, endDate, petId, silent];
}

final class ScheduleEvent$LoadMoreRequested extends ScheduleEvent {
  final DateTime startDate;
  final DateTime endDate;
  final int? petId;

  const ScheduleEvent$LoadMoreRequested({
    required this.startDate,
    required this.endDate,
    this.petId,
  });

  @override
  List<Object?> get props => [startDate, endDate, petId];
}

final class ScheduleEvent$MarkDoneRequested extends ScheduleEvent {
  final String eventId;
  final DateTime date;
  final bool value;

  /// Локальное время вхождения: у события с несколькими временами в день это отдельные записи.
  final String? time;

  const ScheduleEvent$MarkDoneRequested({
    required this.eventId,
    required this.date,
    required this.value,
    this.time,
  });

  @override
  List<Object?> get props => [eventId, date, value, time];
}

final class ScheduleEvent$OccurrenceCancelledChanged extends ScheduleEvent {
  final EventOccurrenceRef ref;
  final bool cancelled;
  final bool dropFollowing;

  const ScheduleEvent$OccurrenceCancelledChanged({
    required this.ref,
    required this.cancelled,
    this.dropFollowing = false,
  });

  @override
  List<Object?> get props => [ref, cancelled, dropFollowing];
}

final class ScheduleEvent$OccurrenceReplaced extends ScheduleEvent {
  final ScheduleEventModel occurrence;

  const ScheduleEvent$OccurrenceReplaced({required this.occurrence});

  @override
  List<Object?> get props => [occurrence];
}

final class ScheduleEvent$RefreshRequested extends ScheduleEvent {
  final Completer<void>? completer;

  const ScheduleEvent$RefreshRequested({this.completer});

  @override
  List<Object?> get props => [];
}
