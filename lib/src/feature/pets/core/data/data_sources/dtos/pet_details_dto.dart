import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/breed_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

part 'pet_details_dto.g.dart';

@JsonSerializable()
class PetDetailsDto extends Equatable {
  final int id;
  final PetTypeEnum petType;
  final String name;
  @JsonKey(name: 'breed_obj')
  final BreedDto breed;
  final PetSexEnum gender;
  final DateTime birthday;
  final String color;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetDetailsDto({
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

  factory PetDetailsDto.fromJson(Map<String, dynamic> json) => _$PetDetailsDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$PetDetailsDtoToJson(this);

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
