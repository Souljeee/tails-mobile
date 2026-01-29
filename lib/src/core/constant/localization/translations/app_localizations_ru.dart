// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Хвостики';

  @override
  String get enterCodeTitle => 'Ввод кода\nподтверждения';

  @override
  String get enterCodeSubtitle => 'Вам позвонит робот на номер';

  @override
  String get callAgain => 'Перезвонить еще раз';

  @override
  String get tryLater => 'Произошла ошибка. Попробуйте позже.';

  @override
  String petAgeYears(int years) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years лет',
      many: '$years лет',
      few: '$years года',
      one: '$years год',
    );
    return '$_temp0';
  }

  @override
  String petAgeMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months месяцев',
      many: '$months месяцев',
      few: '$months месяца',
      one: '$months месяц',
    );
    return '$_temp0';
  }

  @override
  String petAgeYearsAndMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years лет',
      many: '$years лет',
      few: '$years года',
      one: '$years год',
    );
    String _temp1 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months месяцев',
      many: '$months месяцев',
      few: '$months месяца',
      one: '$months месяц',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String get dog => 'Собака';

  @override
  String get cat => 'Кошка';
}
