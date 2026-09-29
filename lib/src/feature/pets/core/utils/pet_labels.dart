import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_age.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_weight_format.dart';

/// Возраст питомца в сокращённом виде: `2 года 8 мес.`, `2 года`, `5 мес.`.
String formatPetAgeShort(AppLocalizations l10n, PetAge age) {
  if (age.years == 0) {
    return l10n.petAgeShortMonths(age.months);
  }

  if (age.months == 0) {
    return l10n.petAgeYears(age.years);
  }

  return l10n.petAgeShortYearsMonths(age.years, age.months);
}

/// Вес питомца с единицей: `14,9 кг`.
String formatPetWeightLabel(AppLocalizations l10n, double weightKg) =>
    l10n.petWeightKg(formatPetWeight(weightKg));
