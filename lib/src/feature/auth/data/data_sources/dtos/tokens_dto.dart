import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tokens_dto.g.dart';

@JsonSerializable()
class TokensDto extends Equatable {
  final String access;
  final String refresh;
  final int accessExpires;
  final int refreshExpires;

  const TokensDto({
    required this.access,
    required this.refresh,
    required this.accessExpires,
    required this.refreshExpires,
  });

  factory TokensDto.fromJson(Map<String, dynamic> json) => _$TokensDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TokensDtoToJson(this);

  @override
  List<Object?> get props => [
        access,
        refresh,
        accessExpires,
        refreshExpires,
      ];
}
