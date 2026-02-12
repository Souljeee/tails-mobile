import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';


class EditPetModel extends Equatable {
  final String? name;
  final PetTypeEnum? petType;
  final int? breedId;
  final String? color;
  final double? weight;
  final PetSexEnum? gender;
  final DateTime? birthday;
  final bool? hasCastration;

  const EditPetModel({
    this.name,
    this.petType,
    this.breedId,
    this.color,
    this.weight,
    this.gender,
    this.birthday,
    this.hasCastration,
  });

  @override
  List<Object?> get props => [
        name,
        petType,
        breedId,
        color,
        weight,
        gender,
        birthday,
        hasCastration,
      ];
}
