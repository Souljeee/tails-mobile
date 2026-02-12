import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

class PetDetailsModel extends Equatable{
  final int id;
  final PetTypeEnum petType;
  final String name;
  final BreedModel breed;
  final PetSexEnum gender;
  final DateTime birthday;
  final String color;
  final String image;
  final double weight;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasCastration;

  const PetDetailsModel({
    required this.id,
    required this.petType,
    required this.name,
    required this.breed,
    required this.gender,
    required this.birthday,
    required this.color,
    required this.image,
    required this.weight,
    required this.createdAt,
    required this.updatedAt,
    required this.hasCastration,
  });
  
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
    weight,
    createdAt,
    updatedAt,
    hasCastration,
  ];
}
