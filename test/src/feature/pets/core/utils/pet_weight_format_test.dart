import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_weight_format.dart';

void main() {
  group('formatPetWeight', () {
    test('использует запятую как разделитель', () {
      expect(formatPetWeight(14.9), '14,9');
    });

    test('убирает нулевую дробную часть', () {
      expect(formatPetWeight(15), '15');
      expect(formatPetWeight(10), '10');
      expect(formatPetWeight(100), '100');
    });

    test('сохраняет до двух знаков после запятой', () {
      expect(formatPetWeight(4.25), '4,25');
      expect(formatPetWeight(0.5), '0,5');
    });

    test('округляет до двух знаков', () {
      expect(formatPetWeight(14.999), '15');
    });
  });
}
