import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

class AddPetModel extends Equatable {
  final String name;
  final PetTypeEnum petType;
  final String breed;
  final String color;
  final double weight;
  final PetSexEnum gender;
  final DateTime birthday;
  final bool hasCastration;

  const AddPetModel({
    required this.name,
    required this.petType,
    required this.breed,
    required this.color,
    required this.weight,
    required this.gender,
    required this.birthday,
    required this.hasCastration,
  });

  @override
  List<Object?> get props => [
        name,
        petType,
        breed,
        color,
        weight,
        gender,
        birthday,
        hasCastration,
      ];
}
