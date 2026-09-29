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

  /// No description provided for @deletePetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить питомца'**
  String get deletePetTitle;

  /// No description provided for @deletePetSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить этого питомца? Это действие нельзя будет отменить.'**
  String get deletePetSubtitle;

  /// No description provided for @deletePetCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get deletePetCancel;

  /// No description provided for @deletePetDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get deletePetDelete;

  /// No description provided for @all.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all;

  /// No description provided for @navPets.
  ///
  /// In ru, this message translates to:
  /// **'Питомцы'**
  String get navPets;

  /// No description provided for @navCalendar.
  ///
  /// In ru, this message translates to:
  /// **'Календарь'**
  String get navCalendar;

  /// No description provided for @navProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get navProfile;

  /// No description provided for @navAddPet.
  ///
  /// In ru, this message translates to:
  /// **'Добавить питомца'**
  String get navAddPet;

  /// No description provided for @navAddEvent.
  ///
  /// In ru, this message translates to:
  /// **'Добавить событие'**
  String get navAddEvent;

  /// No description provided for @authSlide1Title.
  ///
  /// In ru, this message translates to:
  /// **'Профиль любимца'**
  String get authSlide1Title;

  /// No description provided for @authSlide1Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Имя, порода, дата рождения и заметки — чтобы ничего не терялось.'**
  String get authSlide1Subtitle;

  /// No description provided for @authSlide2Title.
  ///
  /// In ru, this message translates to:
  /// **'Календарь питомца'**
  String get authSlide2Title;

  /// No description provided for @authSlide2Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Все запланированные события в одном списке и по датам.'**
  String get authSlide2Subtitle;

  /// No description provided for @authSlide3Title.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не забыть'**
  String get authSlide3Title;

  /// No description provided for @authSlide3Subtitle.
  ///
  /// In ru, this message translates to:
  /// **'Создавайте напоминания о важных делах для питомца за пару секунд.'**
  String get authSlide3Subtitle;

  /// No description provided for @authPhoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите ваш номер телефона'**
  String get authPhoneTitle;

  /// No description provided for @authPhoneSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Мы отправим вам безопасный код подтверждения'**
  String get authPhoneSubtitle;

  /// No description provided for @authPhoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get authPhoneLabel;

  /// No description provided for @authGetCode.
  ///
  /// In ru, this message translates to:
  /// **'Получить код'**
  String get authGetCode;

  /// No description provided for @authConsentPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Нажимая «Получить код», вы соглашаетесь с нашими '**
  String get authConsentPrefix;

  /// No description provided for @authTerms.
  ///
  /// In ru, this message translates to:
  /// **'Условиями использования'**
  String get authTerms;

  /// No description provided for @authConsentAnd.
  ///
  /// In ru, this message translates to:
  /// **' и '**
  String get authConsentAnd;

  /// No description provided for @authPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Политикой конфиденциальности'**
  String get authPrivacy;

  /// No description provided for @enterCodeBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get enterCodeBack;

  /// Подпись поля ввода одной цифры кода для скринридера
  ///
  /// In ru, this message translates to:
  /// **'Цифра {index} из {count}'**
  String enterCodeDigitLabel(int index, int count);

  /// No description provided for @scheduleToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get scheduleToday;

  /// Подпись под заголовком календаря: число дел на сегодня
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Нет дел на сегодня} one{{count} дело на сегодня} few{{count} дела на сегодня} many{{count} дел на сегодня} other{{count} дела на сегодня}}'**
  String scheduleTodayCount(int count);

  /// Число событий выбранного дня
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{Нет событий} one{{count} событие} few{{count} события} many{{count} событий} other{{count} события}}'**
  String scheduleEventsCount(int count);

  /// No description provided for @scheduleAllDay.
  ///
  /// In ru, this message translates to:
  /// **'Весь день'**
  String get scheduleAllDay;

  /// No description provided for @scheduleEmptyDay.
  ///
  /// In ru, this message translates to:
  /// **'На этот день событий нет'**
  String get scheduleEmptyDay;

  /// No description provided for @schedulePreviousMonth.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущий месяц'**
  String get schedulePreviousMonth;

  /// No description provided for @scheduleNextMonth.
  ///
  /// In ru, this message translates to:
  /// **'Следующий месяц'**
  String get scheduleNextMonth;

  /// No description provided for @fetchingErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки'**
  String get fetchingErrorTitle;

  /// No description provided for @fetchingErrorMessage.
  ///
  /// In ru, this message translates to:
  /// **'Повторите позднее'**
  String get fetchingErrorMessage;

  /// No description provided for @fetchingErrorRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get fetchingErrorRetry;

  /// No description provided for @eventTypeDeworming.
  ///
  /// In ru, this message translates to:
  /// **'Дегельминтизация'**
  String get eventTypeDeworming;

  /// No description provided for @eventTypeYearlyVaccination.
  ///
  /// In ru, this message translates to:
  /// **'Годовая вакцинация'**
  String get eventTypeYearlyVaccination;

  /// No description provided for @eventTypeRabiesVaccination.
  ///
  /// In ru, this message translates to:
  /// **'Вакцинация от бешенства'**
  String get eventTypeRabiesVaccination;

  /// No description provided for @eventTypeWeeklyPills.
  ///
  /// In ru, this message translates to:
  /// **'Недельные таблетки'**
  String get eventTypeWeeklyPills;

  /// No description provided for @eventTypeDailyPills.
  ///
  /// In ru, this message translates to:
  /// **'Лекарства'**
  String get eventTypeDailyPills;

  /// No description provided for @eventTypeGrooming.
  ///
  /// In ru, this message translates to:
  /// **'Уход за шерстью'**
  String get eventTypeGrooming;

  /// No description provided for @eventTypeBathing.
  ///
  /// In ru, this message translates to:
  /// **'Купание'**
  String get eventTypeBathing;

  /// No description provided for @eventTypeWalking.
  ///
  /// In ru, this message translates to:
  /// **'Прогулка'**
  String get eventTypeWalking;

  /// No description provided for @eventTypeFeeding.
  ///
  /// In ru, this message translates to:
  /// **'Кормление'**
  String get eventTypeFeeding;

  /// No description provided for @eventTypeNailTrimming.
  ///
  /// In ru, this message translates to:
  /// **'Стрижка когтей'**
  String get eventTypeNailTrimming;

  /// No description provided for @eventTypeFleaTreatment.
  ///
  /// In ru, this message translates to:
  /// **'Обработка от блох'**
  String get eventTypeFleaTreatment;

  /// No description provided for @eventTypeCustom.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get eventTypeCustom;
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
