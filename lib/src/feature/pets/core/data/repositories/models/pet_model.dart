import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

class PetModel extends Equatable {
  final int id;
  final PetTypeEnum petType;
  final String name;
  final BreedModel breed;
  final String gender;
  final DateTime birthday;
  final String color;
  final String image;

  /// Вес в кг; `null`, если backend его не вернул.
  final double? weight;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Индекс цвета питомца в палитре (`UiPalette.petColor`); одинаков на всех экранах.
  final int colorIndex;

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
    this.weight,
    this.colorIndex = 0,
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
    colorIndex,
  ];
}
