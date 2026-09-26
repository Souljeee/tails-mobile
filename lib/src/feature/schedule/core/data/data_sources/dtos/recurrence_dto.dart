import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recurrence_dto.g.dart';

@JsonSerializable()
class RecurrenceDto extends Equatable {
  final String frequency;
  final int interval;
  @JsonKey(includeIfNull: false)
  final List<int>? weekDays;
  @JsonKey(includeIfNull: false)
  final List<int>? monthDays;
  @JsonKey(includeIfNull: false)
  final String? endType;
  @JsonKey(includeIfNull: false)
  final String? endDate;
  @JsonKey(includeIfNull: false)
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