import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tokens_dto.g.dart';

@JsonSerializable()
class TokensDto extends Equatable {
  final String access;
  final String refresh;
  final int accessExpires;
  final int refreshExpires;

  /// Признак первой успешной верификации номера. Есть только в ответе `verify-code`;
  /// `null`, если бэкенд (старая версия) его не вернул.
  final bool? isNewUser;

  /// Внутренний идентификатор пользователя. Есть только в ответе `verify-code`.
  final String? userId;

  const TokensDto({
    required this.access,
    required this.refresh,
    required this.accessExpires,
    required this.refreshExpires,
    this.isNewUser,
    this.userId,
  });

  factory TokensDto.fromJson(Map<String, dynamic> json) => _$TokensDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TokensDtoToJson(this);

  @override
  List<Object?> get props => [access, refresh, accessExpires, refreshExpires, isNewUser, userId];
}
