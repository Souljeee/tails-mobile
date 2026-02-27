import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

typedef ScheduleEventModelList = Map<DateTime, ScheduleEventModel>;

class ScheduleEventModel extends Equatable {
  final String id;
  final int petId;
  final String title;
  final String? description;
  final String? time;
  final DateTime date;
  final int? timeZoneOffset;
  final ScheduleEventTypeEnum type;
  final bool done;
  final RecurrenceModel? recurrence;

  const ScheduleEventModel({
    required this.id,
    required this.petId,
    required this.title,
    required this.type,
    required this.done,
    required this.date,
    this.description,
    this.time,
    this.timeZoneOffset,
    this.recurrence,
  });

  @override
  List<Object?> get props => [
    id,
    petId,
    title,
    description,
    time,
    date,
    timeZoneOffset,
    type,
    done,
    recurrence,
  ];
}

class RecurrenceModel extends Equatable {
  final String frequency;
  final int interval;
  final List<String>? weekDays;
  final List<int>? monthDays;
  final String endType;
  final String? endDate;
  final int? endCount;

  const RecurrenceModel({
    required this.frequency,
    required this.interval,
    required this.endType,
    this.weekDays,
    this.monthDays,
    this.endDate,
    this.endCount,
  });

  @override
  List<Object?> get props => [frequency, interval, weekDays, monthDays, endType, endDate, endCount];
}
