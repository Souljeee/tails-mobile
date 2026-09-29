import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_age.dart';

void main() {
  group('PetAge.fromBirthday', () {
    test('считает полные годы и месяцы', () {
      final age = PetAge.fromBirthday(DateTime(2024, 1, 15), now: DateTime(2026, 9, 26));

      expect(age, const PetAge(years: 2, months: 8));
    });

    test('не засчитывает неполный месяц', () {
      final age = PetAge.fromBirthday(DateTime(2024, 1, 15), now: DateTime(2026, 9, 14));

      expect(age, const PetAge(years: 2, months: 7));
    });

    test('переносит месяцы в годы при переходе через границу года', () {
      final age = PetAge.fromBirthday(DateTime(2024, 11, 20), now: DateTime(2026, 2, 20));

      expect(age, const PetAge(years: 1, months: 3));
    });

    test('возраст младше месяца равен нулю', () {
      final age = PetAge.fromBirthday(DateTime(2026, 9, 10), now: DateTime(2026, 9, 26));

      expect(age, const PetAge(years: 0, months: 0));
    });

    test('дата рождения в будущем даёт нулевой возраст', () {
      final age = PetAge.fromBirthday(DateTime(2027), now: DateTime(2026, 9, 26));

      expect(age, const PetAge(years: 0, months: 0));
    });
  });
}
