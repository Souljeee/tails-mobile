import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'recurrence_dto.g.dart';

@JsonSerializable()
class RecurrenceDto extends Equatable {
  /// `daily | weekly | monthly | yearly` (строкой: неизвестное значение не должно ломать разбор).
  final String frequency;
  @JsonKey(defaultValue: 1)
  final int interval;
  @JsonKey(includeIfNull: false)
  final List<int>? weekDays;

  /// 1–31 и `-1` («последний день»).
  @JsonKey(includeIfNull: false)
  final List<int>? monthDays;
  @JsonKey(includeIfNull: false)
  final List<YearDateDto>? yearDates;

  /// Времена «HH:mm» в UTC (только при нескольких временах в день).
  @JsonKey(includeIfNull: false)
  final List<String>? times;

  /// `never | date | count`; сервер в ответе вычисляет его из [endDate] / [endCount].
  @JsonKey(includeIfNull: false)
  final String? endType;
  @JsonKey(includeIfNull: false)
  final String? endDate;
  @JsonKey(includeIfNull: false)
  final int? endCount;

  const RecurrenceDto({
    required this.frequency,
    this.interval = 1,
    this.weekDays,
    this.monthDays,
    this.yearDates,
    this.times,
    this.endType,
    this.endDate,
    this.endCount,
  });

  factory RecurrenceDto.fromJson(Map<String, dynamic> json) => _$RecurrenceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RecurrenceDtoToJson(this);

  @override
  List<Object?> get props => [
    frequency,
    interval,
    weekDays,
    monthDays,
    yearDates,
    times,
    endType,
    endDate,
    endCount,
  ];
}

@JsonSerializable()
class YearDateDto extends Equatable {
  final int month;
  final int day;

  const YearDateDto({required this.month, required this.day});

  factory YearDateDto.fromJson(Map<String, dynamic> json) => _$YearDateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$YearDateDtoToJson(this);

  @override
  List<Object?> get props => [month, day];
}
