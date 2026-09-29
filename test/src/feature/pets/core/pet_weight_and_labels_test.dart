import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations_ru.dart';
import 'package:tails_mobile/src/feature/pets/core/data/data_sources/dtos/pet_dto.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_age.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_labels.dart';

Map<String, dynamic> _json({Object? weight, bool withWeight = true}) => {
  'id': 1,
  'pet_type': 'dog',
  'name': 'Чарли',
  'breed_obj': {'id': 1, 'name': 'Корги'},
  'gender': 'male',
  'birthday': '2024-01-15T00:00:00Z',
  'color': 'рыжий',
  'image': 'https://example.com/1.jpg',
  'created_at': '2025-01-01T00:00:00Z',
  'updated_at': '2025-01-01T00:00:00Z',
  if (withWeight) 'weight': weight,
};

void main() {
  group('PetDto.weight', () {
    test('читает число и строку из JSON', () {
      expect(PetDto.fromJson(_json(weight: 14.9)).weight, 14.9);
      expect(PetDto.fromJson(_json(weight: '4.25')).weight, 4.25);
    });

    test('терпимо относится к отсутствующему или пустому весу', () {
      expect(PetDto.fromJson(_json(withWeight: false)).weight, isNull);
      expect(PetDto.fromJson(_json()).weight, isNull);
    });
  });

  group('подписи питомца', () {
    final l10n = AppLocalizationsRu();

    test('возраст в сокращённом виде', () {
      expect(formatPetAgeShort(l10n, const PetAge(years: 2, months: 8)), '2 года 8 мес.');
      expect(formatPetAgeShort(l10n, const PetAge(years: 5, months: 0)), '5 лет');
      expect(formatPetAgeShort(l10n, const PetAge(years: 0, months: 5)), '5 мес.');
    });

    test('вес с единицей', () {
      expect(formatPetWeightLabel(l10n, 14.9), '14,9 кг');
      expect(formatPetWeightLabel(l10n, 15), '15 кг');
    });
  });
}
