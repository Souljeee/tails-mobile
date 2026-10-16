import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'series_stats_dto.g.dart';

@JsonSerializable()
class SeriesStatsDto extends Equatable {
  const SeriesStatsDto({
    required this.remaining,
    required this.past,
    required this.seriesEnd,
    required this.isOpenEnded,
    required this.cancelledDates,
  });

  final int? remaining;
  final int past;
  final DateTime? seriesEnd;
  final bool isOpenEnded;
  @JsonKey(defaultValue: <DateTime>[])
  final List<DateTime> cancelledDates;

  factory SeriesStatsDto.fromJson(Map<String, dynamic> json) => _$SeriesStatsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesStatsDtoToJson(this);

  @override
  List<Object?> get props => [remaining, past, seriesEnd, isOpenEnded, cancelledDates];
}
