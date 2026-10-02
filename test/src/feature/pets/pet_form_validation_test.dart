import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_form_validation.dart';

void main() {
  group('findMissingPetFormFields', () {
    test('пустая форма: все обязательные поля в порядке расположения', () {
      expect(
        findMissingPetFormFields(
          name: null,
          breedId: null,
          birthday: null,
          weight: null,
          color: null,
        ),
        PetFormField.values,
      );
    });

    test('пробелы вместо кличек и окраса считаются пустыми', () {
      expect(
        findMissingPetFormFields(
          name: '   ',
          breedId: 1,
          birthday: DateTime(2020),
          weight: 5,
          color: '',
        ),
        [PetFormField.name, PetFormField.color],
      );
    });

    test('заполненная форма не даёт ошибок', () {
      expect(
        findMissingPetFormFields(
          name: 'Рекс',
          breedId: 1,
          birthday: DateTime(2020),
          weight: 5,
          color: 'рыжий',
        ),
        isEmpty,
      );
    });
  });
}
