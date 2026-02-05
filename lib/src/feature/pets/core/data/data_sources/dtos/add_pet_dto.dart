import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
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
  final PetSexEnum gender;
  @JsonKey(
    fromJson: _birthdayFromJson,
    toJson: _birthdayToJson,
  )
  final DateTime birthday;
  final bool hasCastration;

  const AddPetDto({
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

  factory AddPetDto.fromJson(Map<String, dynamic> json) => _$AddPetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AddPetDtoToJson(this);

  static String _birthdayToJson(DateTime birthday) => DateFormat('yyyy-MM-dd').format(birthday.toLocal());

  static DateTime _birthdayFromJson(String birthday) => DateFormat('yyyy-MM-dd').parse(birthday);
}
