import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/data_sources/dtos/recurrence_dto.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';

part 'create_event_dto.g.dart';

@JsonSerializable()
class CreateEventDto extends Equatable {
  final String title;
  final String? description;
  final String? time;
  final int? timezoneOffset;
  final DateTime date;
  final int petId;
  final ScheduleEventTypeEnum type;
  final bool isRecurring;
  final RecurrenceDto? recurrence;

  const CreateEventDto({
    required this.petId,
    required this.title,
    required this.description,
    required this.time,
    required this.date,
    required this.type,
    required this.isRecurring,
    this.timezoneOffset,
    this.recurrence,
  });

  factory CreateEventDto.fromJson(Map<String, dynamic> json) => _$CreateEventDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateEventDtoToJson(this);

  @override
  List<Object?> get props => [
    petId,
    title,
    description,
    time,
    date,
    type,
    isRecurring,
    recurrence,
    timezoneOffset,
  ];
}

