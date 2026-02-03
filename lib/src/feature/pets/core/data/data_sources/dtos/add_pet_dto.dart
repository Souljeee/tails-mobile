import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

part 'add_pet_dto.g.dart';

@JsonSerializable()
class AddPetDto extends Equatable {
  final String name;
  final PetTypeEnum petType;
  final String breed;
  final String color;
  final double weight;
  final PetSexEnum sex;
  final DateTime birthDate;
  final bool castration;

  const AddPetDto({
    required this.name,
    required this.petType,
    required this.breed,
    required this.color,
    required this.weight,
    required this.sex,
    required this.birthDate,
    required this.castration,
  });

  @override
  List<Object?> get props => [
        name,
        petType,
        breed,
        color,
        weight,
        sex,
        birthDate,
        castration,
      ];

  factory AddPetDto.fromJson(Map<String, dynamic> json) => _$AddPetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddPetDtoToJson(this);
}
