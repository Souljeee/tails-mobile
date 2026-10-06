import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/breed_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

part 'pet_dto.g.dart';

@JsonSerializable()
class PetDto extends Equatable {
  final int id;
  final PetTypeEnum petType;
  final String name;
  @JsonKey(name: 'breed_obj')
  final BreedDto breed;
  final String gender;
  final DateTime birthday;
  final String color;
  /// Фото питомца; `null` или пустая строка, если пользователь его не загружал.
  final String? image;

  /// Вес в кг. Backend отдаёт поле не для всех версий API, поэтому оно необязательное.
  @JsonKey(fromJson: _weightFromJson)
  final double? weight;
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
    this.image,
    required this.createdAt,
    required this.updatedAt,
    this.weight,
  });

  factory PetDto.fromJson(Map<String, dynamic> json) => _$PetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PetDtoToJson(this);

  static double? _weightFromJson(dynamic weight) =>
      weight == null ? null : double.tryParse(weight.toString());

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
  ];
}
