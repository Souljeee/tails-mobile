/// Обязательные поля формы питомца, которые могут быть не заполнены.
enum PetFormField { name, breed, birthday, weight, color }

/// Возвращает незаполненные обязательные поля в порядке их расположения на форме.
///
/// Вид, пол и «кастрирован» не проверяются: у них всегда есть значение по умолчанию.
List<PetFormField> findMissingPetFormFields({
  required String? name,
  required int? breedId,
  required DateTime? birthday,
  required double? weight,
  required String? color,
}) => [
  if (name == null || name.trim().isEmpty) PetFormField.name,
  if (breedId == null) PetFormField.breed,
  if (birthday == null) PetFormField.birthday,
  if (weight == null) PetFormField.weight,
  if (color == null || color.trim().isEmpty) PetFormField.color,
];
