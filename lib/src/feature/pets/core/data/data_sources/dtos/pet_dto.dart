import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

part 'pet_dto.g.dart';

@JsonSerializable()
class PetDto extends Equatable {
  final String id;
  final PetTypeEnum petType;
  final String name;
  final String breed;
  final String gender;
  final DateTime birthday;
  final String color;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetDto({
    required this.id,
    required this.petType,
    required this.name,
    required this.breed,
    required this.gender,
    required this.birthday,
    required this.color,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PetDto.fromJson(Map<String, dynamic> json) => _$PetDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$PetDtoToJson(this);

  @override
  List<Object?> get props => [
        id,
        petType,
        name,
        breed,
        gender,
        birthday,
        color,
        image,
        createdAt,
        updatedAt,
      ];
}
