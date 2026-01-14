import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tokens_dto.g.dart';

@JsonSerializable()
class TokensDto extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int accessExpires;
  final int refreshExpires;

  const TokensDto({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpires,
    required this.refreshExpires,
  });

  factory TokensDto.fromJson(Map<String, dynamic> json) => _$TokensDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TokensDtoToJson(this);

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        accessExpires,
        refreshExpires,
      ];
}
