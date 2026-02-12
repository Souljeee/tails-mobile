import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'translations/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ru')];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Хвостики'**
  String get appTitle;

  /// No description provided for @enterCodeTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ввод кода\nподтверждения'**
  String get enterCodeTitle;

  /// No description provided for @enterCodeSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Вам позвонит робот на номер'**
  String get enterCodeSubtitle;

  /// No description provided for @callAgain.
  ///
  /// In ru, this message translates to:
  /// **'Перезвонить еще раз'**
  String get callAgain;

  /// No description provided for @tryLater.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка. Попробуйте позже.'**
  String get tryLater;

  /// Возраст питомца в годах с правильным склонением
  ///
  /// In ru, this message translates to:
  /// **'{years, plural, one{{years} год} few{{years} года} many{{years} лет} other{{years} лет}}'**
  String petAgeYears(int years);

  /// Возраст питомца в месяцах с правильным склонением
  ///
  /// In ru, this message translates to:
  /// **'{months, plural, one{{months} месяц} few{{months} месяца} many{{months} месяцев} other{{months} месяцев}}'**
  String petAgeMonths(int months);

  /// Возраст питомца в годах и месяцах с правильным склонением
  ///
  /// In ru, this message translates to:
  /// **'{years, plural, one{{years} год} few{{years} года} many{{years} лет} other{{years} лет}} {months, plural, one{{months} месяц} few{{months} месяца} many{{months} месяцев} other{{months} месяцев}}'**
  String petAgeYearsAndMonths(int years, int months);

  /// No description provided for @dog.
  ///
  /// In ru, this message translates to:
  /// **'Собака'**
  String get dog;

  /// No description provided for @cat.
  ///
  /// In ru, this message translates to:
  /// **'Кошка'**
  String get cat;

  /// No description provided for @monday.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get sunday;

  /// No description provided for @birthday.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get birthday;

  /// No description provided for @color.
  ///
  /// In ru, this message translates to:
  /// **'Окрас'**
  String get color;

  /// No description provided for @status.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get status;

  /// No description provided for @sterilized.
  ///
  /// In ru, this message translates to:
  /// **'Кастрирован'**
  String get sterilized;

  /// No description provided for @weight.
  ///
  /// In ru, this message translates to:
  /// **'Вес'**
  String get weight;

  /// No description provided for @type.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get type;

  /// No description provided for @breed.
  ///
  /// In ru, this message translates to:
  /// **'Порода'**
  String get breed;

  /// No description provided for @gender.
  ///
  /// In ru, this message translates to:
  /// **'Пол'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In ru, this message translates to:
  /// **'Мужской'**
  String get male;

  /// No description provided for @female.
  ///
  /// In ru, this message translates to:
  /// **'Женский'**
  String get female;

  /// No description provided for @error.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
