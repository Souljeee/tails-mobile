import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

part 'edit_pet_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class EditPetDto extends Equatable {
  final String? name;
  final PetTypeEnum? petType;
  @JsonKey(name: 'breed')
  final int? breedId;
  final String? color;
  final double? weight;
  final PetSexEnum? gender;
  @JsonKey(
    fromJson: _birthdayFromJson,
    toJson: _birthdayToJson,
  )
  final DateTime? birthday;
  final bool? hasCastration;

  const EditPetDto({
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

  factory EditPetDto.fromJson(Map<String, dynamic> json) => _$EditPetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$EditPetDtoToJson(this);

  static String? _birthdayToJson(DateTime? birthday) =>
      birthday == null ? null : DateFormat('yyyy-MM-dd').format(birthday.toLocal());

  static DateTime? _birthdayFromJson(String birthday) => DateFormat('yyyy-MM-dd').tryParse(birthday);
}
