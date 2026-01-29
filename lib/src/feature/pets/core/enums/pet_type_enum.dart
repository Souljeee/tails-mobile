import 'package:json_annotation/json_annotation.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';

@JsonEnum()
enum PetTypeEnum {
  dog,
  cat,
}

extension PetTypeEnumExtension on PetTypeEnum {
  String getLocalizedName(AppLocalizations l10n) {
    return switch (this) {
      PetTypeEnum.dog => l10n.dog,
      PetTypeEnum.cat => l10n.cat,
    };
  }
}
