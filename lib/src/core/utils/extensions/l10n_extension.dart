import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/constant/localization/localization.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => Localization.of(this);
}
