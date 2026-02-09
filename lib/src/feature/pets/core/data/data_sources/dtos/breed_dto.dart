import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'breed_dto.g.dart';

@JsonSerializable()
class BreedDto extends Equatable {
  final int id;
  final String name;

  const BreedDto({
    required this.id,
    required this.name,
  });

  factory BreedDto.fromJson(Map<String, dynamic> json) => _$BreedDtoFromJson(json);
  Map<String, dynamic> toJson() => _$BreedDtoToJson(this);

  @override
  List<Object?> get props => [id, name];
}
