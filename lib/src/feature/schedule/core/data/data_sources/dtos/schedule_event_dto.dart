import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

part 'schedule_event_dto.g.dart';

typedef ScheduleEventDtoList = Map<DateTime, List<ScheduleEventDto>>;

@JsonSerializable()
class ScheduleEventDto extends Equatable {
  final String id;
  @JsonKey(name: 'pet')
  final int petId;
  final String title;
  final String? description;
  final String? time;
  @JsonKey(name: 'start_date')
  final DateTime date;
  final int? timeZoneOffset;
  final ScheduleEventTypeEnum type;
  final bool done;
  final RecurrenceDto? recurrence;

  const ScheduleEventDto({
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

  factory ScheduleEventDto.fromJson(Map<String, dynamic> json) => _$ScheduleEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleEventDtoToJson(this);

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

@JsonSerializable()
class RecurrenceDto extends Equatable {
  final String frequency;
  final int interval;
  final List<String>? weekDays;
  final List<int>? monthDays;
  final String endType;
  final String? endDate;
  final int? endCount;

  const RecurrenceDto({
    required this.frequency,
    required this.interval,
    required this.endType,
    this.weekDays,
    this.monthDays,
    this.endDate,
    this.endCount,
  });

  factory RecurrenceDto.fromJson(Map<String, dynamic> json) => _$RecurrenceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecurrenceDtoToJson(this);

  @override
  List<Object?> get props => [frequency, interval, weekDays, monthDays, endType, endDate, endCount];
}
