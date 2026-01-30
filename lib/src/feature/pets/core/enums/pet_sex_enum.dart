import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum PetSexEnum {
  male,
  female,
}

extension PetSexEnumExtension on PetSexEnum {
  String get shortName => switch (this) {
        PetSexEnum.male => 'Муж.',
        PetSexEnum.female => 'Жен.',
      };
}