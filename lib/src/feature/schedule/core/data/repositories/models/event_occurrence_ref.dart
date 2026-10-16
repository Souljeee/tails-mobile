import 'package:equatable/equatable.dart';

/// Адрес конкретного вхождения события: серия + дата + (при нескольких временах в день) слот.
///
/// Им пользуются ключи списков, отметка выполнения, отмена и возврат. [time] — локальное время
/// вхождения `HH:mm` (как в модели), `null` у события «весь день». [timeZoneOffset] нужен только
/// для перевода времени в UTC при запросах и в равенстве не участвует.
class EventOccurrenceRef extends Equatable {
  EventOccurrenceRef({
    required this.eventId,
    required DateTime date,
    this.time,
    this.timeZoneOffset,
  }) : date = DateTime(date.year, date.month, date.day);

  final String eventId;

  /// Локальная дата вхождения без времени суток.
  final DateTime date;
  final String? time;
  final int? timeZoneOffset;

  @override
  List<Object?> get props => [eventId, date, time];
}
