import 'package:json_annotation/json_annotation.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/core/ui_kit/generated/assets.gen.dart';

@JsonEnum()
enum PetTypeEnum {
  dog,
  cat,
}

extension PetTypeEnumExtension on PetTypeEnum {
  /// Путь к заглушке фото питомца, когда своего фото у него нет.
  String get emptyAvatarAsset => switch (this) {
    PetTypeEnum.dog => UiAssets.images.dogEmptyAvatar.path,
    PetTypeEnum.cat => UiAssets.images.catEmptyAvatar.path,
  };

  String getLocalizedName(AppLocalizations l10n) {
    return switch (this) {
      PetTypeEnum.dog => l10n.dog,
      PetTypeEnum.cat => l10n.cat,
    };
  }
}
