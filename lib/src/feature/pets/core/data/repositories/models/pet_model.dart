import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

class PetModel extends Equatable{
  final int id;
  final PetTypeEnum petType;
  final String name;
  final String breed;
  final String gender;
  final DateTime birthday;
  final String color;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PetModel({
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
