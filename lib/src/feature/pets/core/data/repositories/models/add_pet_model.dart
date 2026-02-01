import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

class AddPetModel extends Equatable {
  final String name;
  final PetTypeEnum petType;
  final String breed;
  final String color;
  final String weight;
  final PetSexEnum sex;
  final DateTime birthDate;
  final bool castration;

  const AddPetModel({
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
}
