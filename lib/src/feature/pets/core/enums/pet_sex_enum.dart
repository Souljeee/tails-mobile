import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum PetSexEnum {
  @JsonValue('M')
  male,
  @JsonValue('F')
  female,
}
