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

  /// No description provided for @eventTypeVetVisit.
  ///
  /// In ru, this message translates to:
  /// **'Визит к ветеринару'**
  String get eventTypeVetVisit;

  /// No description provided for @eventTypeCustom.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get eventTypeCustom;

  /// No description provided for @cancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// No description provided for @createEventTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новое событие'**
  String get createEventTitle;

  /// No description provided for @createEventForWhom.
  ///
  /// In ru, this message translates to:
  /// **'Для кого'**
  String get createEventForWhom;

  /// No description provided for @createEventNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get createEventNameLabel;

  /// No description provided for @createEventNamePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Например, «Покормить кота»'**
  String get createEventNamePlaceholder;

  /// No description provided for @createEventTypeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get createEventTypeLabel;

  /// No description provided for @createEventDateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get createEventDateLabel;

  /// No description provided for @createEventDatePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'ДД.ММ.ГГГГ'**
  String get createEventDatePlaceholder;

  /// No description provided for @createEventTimeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get createEventTimeLabel;

  /// No description provided for @createEventTimePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'чч:мм'**
  String get createEventTimePlaceholder;

  /// No description provided for @createEventRecurrenceLabel.
  ///
  /// In ru, this message translates to:
  /// **'Повторение'**
  String get createEventRecurrenceLabel;

  /// No description provided for @createEventNoRecurrence.
  ///
  /// In ru, this message translates to:
  /// **'Не повторять'**
  String get createEventNoRecurrence;

  /// No description provided for @createEventNotesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Заметки · необязательно'**
  String get createEventNotesLabel;

  /// No description provided for @createEventNotesPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте детали...'**
  String get createEventNotesPlaceholder;

  /// No description provided for @createEventSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Создать событие'**
  String get createEventSubmit;

  /// No description provided for @eventChipTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get eventChipTime;

  /// No description provided for @timePickerClear.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get timePickerClear;

  /// No description provided for @petsOverviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Мои питомцы'**
  String get petsOverviewTitle;

  /// Число питомцев в подписи под заголовком
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} питомец} few{{count} питомца} many{{count} питомцев} other{{count} питомца}}'**
  String petsCount(int count);

  /// Число дел на сегодня в подписи под заголовком
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{сегодня дел нет} one{сегодня {count} дело} few{сегодня {count} дела} many{сегодня {count} дел} other{сегодня {count} дела}}'**
  String petsTodayEvents(int count);

  /// No description provided for @petsEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Список ваших питомцев пуст'**
  String get petsEmptyTitle;

  /// No description provided for @petsEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Расскажите нам о ваших любимцах'**
  String get petsEmptyMessage;

  /// No description provided for @notificationsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notificationsLabel;

  /// Возраст питомца: годы и месяцы в сокращённом виде
  ///
  /// In ru, this message translates to:
  /// **'{years, plural, one{{years} год} few{{years} года} many{{years} лет} other{{years} лет}} {months} мес.'**
  String petAgeShortYearsMonths(int years, int months);

  /// Возраст питомца младше года
  ///
  /// In ru, this message translates to:
  /// **'{months} мес.'**
  String petAgeShortMonths(int months);

  /// Вес питомца в килограммах
  ///
  /// In ru, this message translates to:
  /// **'{weight} кг'**
  String petWeightKg(String weight);

  /// No description provided for @petNextEventToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get petNextEventToday;

  /// No description provided for @petNextEventTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get petNextEventTomorrow;

  /// No description provided for @breedPageTitleCat.
  ///
  /// In ru, this message translates to:
  /// **'Порода · кошки'**
  String get breedPageTitleCat;

  /// No description provided for @breedPageTitleDog.
  ///
  /// In ru, this message translates to:
  /// **'Порода · собаки'**
  String get breedPageTitleDog;

  /// No description provided for @breedSearchPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Найти породу'**
  String get breedSearchPlaceholder;

  /// No description provided for @breedNothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get breedNothingFound;

  /// No description provided for @breedMixedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Метис или не знаю'**
  String get breedMixedLabel;

  /// No description provided for @addPetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый питомец'**
  String get addPetTitle;

  /// No description provided for @editPetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Изменить питомца'**
  String get editPetTitle;

  /// No description provided for @addPetSubmit.
  ///
  /// In ru, this message translates to:
  /// **'Добавить питомца'**
  String get addPetSubmit;

  /// No description provided for @savePet.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get savePet;

  /// No description provided for @petFormMain.
  ///
  /// In ru, this message translates to:
  /// **'Основное'**
  String get petFormMain;

  /// No description provided for @petFormDetails.
  ///
  /// In ru, this message translates to:
  /// **'Детали'**
  String get petFormDetails;

  /// No description provided for @petFormKind.
  ///
  /// In ru, this message translates to:
  /// **'Вид'**
  String get petFormKind;

  /// No description provided for @petFormName.
  ///
  /// In ru, this message translates to:
  /// **'Кличка'**
  String get petFormName;

  /// No description provided for @petFormNamePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Например, Барсик'**
  String get petFormNamePlaceholder;

  /// No description provided for @petFormSex.
  ///
  /// In ru, this message translates to:
  /// **'Пол'**
  String get petFormSex;

  /// No description provided for @petSexMale.
  ///
  /// In ru, this message translates to:
  /// **'Мужской'**
  String get petSexMale;

  /// No description provided for @petSexFemale.
  ///
  /// In ru, this message translates to:
  /// **'Женский'**
  String get petSexFemale;

  /// No description provided for @petFormBreed.
  ///
  /// In ru, this message translates to:
  /// **'Порода'**
  String get petFormBreed;

  /// No description provided for @petFormBreedPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Выберите породу'**
  String get petFormBreedPlaceholder;

  /// No description provided for @petFormBirthday.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get petFormBirthday;

  /// No description provided for @petFormBirthdayHint.
  ///
  /// In ru, this message translates to:
  /// **'Если не знаете точно — укажите примерную дату'**
  String get petFormBirthdayHint;

  /// No description provided for @petFormWeight.
  ///
  /// In ru, this message translates to:
  /// **'Вес'**
  String get petFormWeight;

  /// No description provided for @petFormWeightPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Выберите'**
  String get petFormWeightPlaceholder;

  /// No description provided for @petFormColor.
  ///
  /// In ru, this message translates to:
  /// **'Окрас'**
  String get petFormColor;

  /// No description provided for @petFormColorPlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Например, рыжий'**
  String get petFormColorPlaceholder;

  /// No description provided for @petCastratedMale.
  ///
  /// In ru, this message translates to:
  /// **'Кастрирован'**
  String get petCastratedMale;

  /// No description provided for @petCastratedFemale.
  ///
  /// In ru, this message translates to:
  /// **'Стерилизована'**
  String get petCastratedFemale;

  /// No description provided for @petCastratedHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно изменить позже в профиле'**
  String get petCastratedHint;

  /// No description provided for @petPhotoAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить фото'**
  String get petPhotoAdd;

  /// No description provided for @petPhotoChange.
  ///
  /// In ru, this message translates to:
  /// **'Изменить фото'**
  String get petPhotoChange;

  /// No description provided for @petPhotoHint.
  ///
  /// In ru, this message translates to:
  /// **'Фото поможет быстрее находить питомца'**
  String get petPhotoHint;

  /// No description provided for @photoSourceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить фото'**
  String get photoSourceTitle;

  /// No description provided for @photoSourceGallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get photoSourceGallery;

  /// No description provided for @photoSourceCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get photoSourceCamera;

  /// No description provided for @photoPickError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось выбрать фото'**
  String get photoPickError;

  /// No description provided for @weightKgUnit.
  ///
  /// In ru, this message translates to:
  /// **'кг'**
  String get weightKgUnit;

  /// No description provided for @weightGramsUnit.
  ///
  /// In ru, this message translates to:
  /// **'г'**
  String get weightGramsUnit;

  /// No description provided for @done.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done;

  /// No description provided for @selectAction.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get selectAction;

  /// No description provided for @pickBirthDateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get pickBirthDateTitle;

  /// No description provided for @navBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get navBack;

  /// No description provided for @petDetailsMenu.
  ///
  /// In ru, this message translates to:
  /// **'Меню'**
  String get petDetailsMenu;

  /// No description provided for @petDetailsAge.
  ///
  /// In ru, this message translates to:
  /// **'Возраст'**
  String get petDetailsAge;

  /// No description provided for @petDetailsEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get petDetailsEdit;

  /// No description provided for @petDetailsUpcoming.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшие события'**
  String get petDetailsUpcoming;

  /// No description provided for @petDetailsNoEvents.
  ///
  /// In ru, this message translates to:
  /// **'В ближайшие две недели событий нет'**
  String get petDetailsNoEvents;

  /// No description provided for @petFormErrorName.
  ///
  /// In ru, this message translates to:
  /// **'Введите кличку'**
  String get petFormErrorName;

  /// No description provided for @petFormErrorBreed.
  ///
  /// In ru, this message translates to:
  /// **'Выберите породу'**
  String get petFormErrorBreed;

  /// No description provided for @petFormErrorBirthday.
  ///
  /// In ru, this message translates to:
  /// **'Укажите дату рождения'**
  String get petFormErrorBirthday;

  /// No description provided for @petFormErrorWeight.
  ///
  /// In ru, this message translates to:
  /// **'Укажите вес'**
  String get petFormErrorWeight;

  /// No description provided for @petFormErrorColor.
  ///
  /// In ru, this message translates to:
  /// **'Введите окрас'**
  String get petFormErrorColor;

  /// No description provided for @createEventErrorPet.
  ///
  /// In ru, this message translates to:
  /// **'Выберите питомца'**
  String get createEventErrorPet;

  /// No description provided for @createEventErrorTitle.
  ///
  /// In ru, this message translates to:
  /// **'Введите название'**
  String get createEventErrorTitle;

  /// No description provided for @discardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть без сохранения?'**
  String get discardTitle;

  /// No description provided for @discardMessage.
  ///
  /// In ru, this message translates to:
  /// **'Введённые данные будут потеряны.'**
  String get discardMessage;

  /// No description provided for @discardKeepEditing.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get discardKeepEditing;

  /// No description provided for @discardConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get discardConfirm;

  /// No description provided for @petsScheduleUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить события'**
  String get petsScheduleUnavailable;

  /// Союз в перечислениях правила повторения
  ///
  /// In ru, this message translates to:
  /// **'и'**
  String get recurrenceAnd;

  /// No description provided for @recurrenceEveryDay.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get recurrenceEveryDay;

  /// No description provided for @recurrenceEveryOtherDay.
  ///
  /// In ru, this message translates to:
  /// **'Через день'**
  String get recurrenceEveryOtherDay;

  /// No description provided for @recurrenceEveryNDays.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{Каждый {n} день} few{Каждые {n} дня} many{Каждые {n} дней} other{Каждые {n} дня}}'**
  String recurrenceEveryNDays(int n);

  /// No description provided for @recurrenceWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'По будням'**
  String get recurrenceWeekdays;

  /// No description provided for @recurrenceWeekends.
  ///
  /// In ru, this message translates to:
  /// **'По выходным'**
  String get recurrenceWeekends;

  /// Один день недели в итоге правила
  ///
  /// In ru, this message translates to:
  /// **'{weekday, select, 1{Каждый понедельник} 2{Каждый вторник} 3{Каждую среду} 4{Каждый четверг} 5{Каждую пятницу} 6{Каждую субботу} 7{Каждое воскресенье} other{}}'**
  String recurrenceEveryWeekday(String weekday);

  /// День недели во множественном числе, дательный падеж («по вторникам»)
  ///
  /// In ru, this message translates to:
  /// **'{weekday, select, 1{понедельникам} 2{вторникам} 3{средам} 4{четвергам} 5{пятницам} 6{субботам} 7{воскресеньям} other{}}'**
  String recurrenceWeekdayDative(String weekday);

  /// No description provided for @recurrenceOnWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'По {days}'**
  String recurrenceOnWeekdays(String days);

  /// No description provided for @recurrenceEveryNWeeksOn.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{Каждую {n} неделю} few{Каждые {n} недели} many{Каждые {n} недель} other{Каждые {n} недели}} по {days}'**
  String recurrenceEveryNWeeksOn(int n, String days);

  /// No description provided for @recurrenceMonthEvery.
  ///
  /// In ru, this message translates to:
  /// **'каждого месяца'**
  String get recurrenceMonthEvery;

  /// No description provided for @recurrenceMonthEveryN.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{каждый {n} месяц} few{каждые {n} месяца} many{каждые {n} месяцев} other{каждые {n} месяца}}'**
  String recurrenceMonthEveryN(int n);

  /// No description provided for @recurrenceMonthNumbers.
  ///
  /// In ru, this message translates to:
  /// **'{days} числа {every}'**
  String recurrenceMonthNumbers(String days, String every);

  /// No description provided for @recurrenceMonthLast.
  ///
  /// In ru, this message translates to:
  /// **'В последний день {every}'**
  String recurrenceMonthLast(String every);

  /// No description provided for @recurrenceMonthNumbersAndLast.
  ///
  /// In ru, this message translates to:
  /// **'{days} числа и в последний день {every}'**
  String recurrenceMonthNumbersAndLast(String days, String every);

  /// Название месяца в родительном падеже («15 марта»)
  ///
  /// In ru, this message translates to:
  /// **'{month, select, 1{января} 2{февраля} 3{марта} 4{апреля} 5{мая} 6{июня} 7{июля} 8{августа} 9{сентября} 10{октября} 11{ноября} 12{декабря} other{}}'**
  String recurrenceMonthGenitive(String month);

  /// No description provided for @recurrenceDayMonth.
  ///
  /// In ru, this message translates to:
  /// **'{day} {month}'**
  String recurrenceDayMonth(int day, String month);

  /// No description provided for @recurrenceYearEvery.
  ///
  /// In ru, this message translates to:
  /// **'{dates} каждого года'**
  String recurrenceYearEvery(String dates);

  /// No description provided for @recurrenceYearEveryN.
  ///
  /// In ru, this message translates to:
  /// **'{dates}, {n, plural, one{каждый {n} год} few{каждые {n} года} many{каждые {n} лет} other{каждые {n} года}}'**
  String recurrenceYearEveryN(String dates, int n);

  /// No description provided for @recurrenceOncePerWeek.
  ///
  /// In ru, this message translates to:
  /// **'раз в неделю'**
  String get recurrenceOncePerWeek;

  /// No description provided for @recurrenceOncePerMonth.
  ///
  /// In ru, this message translates to:
  /// **'раз в месяц'**
  String get recurrenceOncePerMonth;

  /// No description provided for @recurrenceOncePerYear.
  ///
  /// In ru, this message translates to:
  /// **'раз в год'**
  String get recurrenceOncePerYear;

  /// No description provided for @recurrenceTimesPerDay.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, few{{n} раза} other{{n} раз}} в день'**
  String recurrenceTimesPerDay(int n);

  /// No description provided for @recurrenceTimesPerWeek.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, few{{n} раза} other{{n} раз}} в неделю'**
  String recurrenceTimesPerWeek(int n);

  /// No description provided for @recurrenceTimesPerMonth.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, few{{n} раза} other{{n} раз}} в месяц'**
  String recurrenceTimesPerMonth(int n);

  /// No description provided for @recurrenceTimesPerYear.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, few{{n} раза} other{{n} раз}} в год'**
  String recurrenceTimesPerYear(int n);

  /// No description provided for @recurrenceOnceInUnits.
  ///
  /// In ru, this message translates to:
  /// **'раз в {unit}'**
  String recurrenceOnceInUnits(String unit);

  /// No description provided for @recurrenceTimesInUnits.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, few{{n} раза} other{{n} раз}} за {unit}'**
  String recurrenceTimesInUnits(int n, String unit);

  /// No description provided for @recurrenceUnitWeeks.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{{n} неделю} few{{n} недели} many{{n} недель} other{{n} недели}}'**
  String recurrenceUnitWeeks(int n);

  /// No description provided for @recurrenceUnitMonths.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{{n} месяц} few{{n} месяца} many{{n} месяцев} other{{n} месяца}}'**
  String recurrenceUnitMonths(int n);

  /// No description provided for @recurrenceUnitYears.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{{n} год} few{{n} года} many{{n} лет} other{{n} года}}'**
  String recurrenceUnitYears(int n);

  /// No description provided for @recurrenceAtTime.
  ///
  /// In ru, this message translates to:
  /// **'в {time}'**
  String recurrenceAtTime(String time);

  /// No description provided for @recurrenceEndUntil.
  ///
  /// In ru, this message translates to:
  /// **'до {date}'**
  String recurrenceEndUntil(String date);

  /// No description provided for @recurrenceEndAfter.
  ///
  /// In ru, this message translates to:
  /// **'после {n, plural, one{{n} повторения} other{{n} повторений}}'**
  String recurrenceEndAfter(int n);

  /// No description provided for @recurrenceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Повторение'**
  String get recurrenceTitle;

  /// No description provided for @recurrenceReset.
  ///
  /// In ru, this message translates to:
  /// **'Не повторять'**
  String get recurrenceReset;

  /// No description provided for @recurrenceNext.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшие: {dates}'**
  String recurrenceNext(String dates);

  /// No description provided for @recurrencePeriodDay.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get recurrencePeriodDay;

  /// No description provided for @recurrencePeriodWeek.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get recurrencePeriodWeek;

  /// No description provided for @recurrencePeriodMonth.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get recurrencePeriodMonth;

  /// No description provided for @recurrencePeriodYear.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get recurrencePeriodYear;

  /// No description provided for @recurrenceWeekdayShort.
  ///
  /// In ru, this message translates to:
  /// **'{weekday, select, 1{Пн} 2{Вт} 3{Ср} 4{Чт} 5{Пт} 6{Сб} 7{Вс} other{}}'**
  String recurrenceWeekdayShort(String weekday);

  /// No description provided for @recurrencePresetWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'Будни'**
  String get recurrencePresetWeekdays;

  /// No description provided for @recurrencePresetWeekend.
  ///
  /// In ru, this message translates to:
  /// **'Выходные'**
  String get recurrencePresetWeekend;

  /// No description provided for @recurrencePresetAllDays.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get recurrencePresetAllDays;

  /// No description provided for @recurrenceLastDay.
  ///
  /// In ru, this message translates to:
  /// **'Последний день'**
  String get recurrenceLastDay;

  /// No description provided for @recurrenceMonthTransferHint.
  ///
  /// In ru, this message translates to:
  /// **'В коротких месяцах событие переносится на последний день — например, {examples}'**
  String recurrenceMonthTransferHint(String examples);

  /// No description provided for @recurrenceFeb29Hint.
  ///
  /// In ru, this message translates to:
  /// **'В невисокосный год событие перенесётся на 28 февраля'**
  String get recurrenceFeb29Hint;

  /// No description provided for @recurrenceTimeN.
  ///
  /// In ru, this message translates to:
  /// **'Время {n}'**
  String recurrenceTimeN(int n);

  /// No description provided for @recurrenceEndTitle.
  ///
  /// In ru, this message translates to:
  /// **'Окончание'**
  String get recurrenceEndTitle;

  /// No description provided for @recurrenceEndNever.
  ///
  /// In ru, this message translates to:
  /// **'Без окончания'**
  String get recurrenceEndNever;

  /// No description provided for @recurrenceEndOnDate.
  ///
  /// In ru, this message translates to:
  /// **'До определённой даты'**
  String get recurrenceEndOnDate;

  /// No description provided for @recurrenceEndAfterCount.
  ///
  /// In ru, this message translates to:
  /// **'После нескольких повторений'**
  String get recurrenceEndAfterCount;

  /// No description provided for @recurrenceEndErrorBeforeStart.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания раньше даты события'**
  String get recurrenceEndErrorBeforeStart;

  /// No description provided for @recurrenceEndErrorBeforeFirst.
  ///
  /// In ru, this message translates to:
  /// **'Первое повторение — {date}, дата окончания раньше'**
  String recurrenceEndErrorBeforeFirst(String date);

  /// No description provided for @recurrenceDecrease.
  ///
  /// In ru, this message translates to:
  /// **'Уменьшить'**
  String get recurrenceDecrease;

  /// No description provided for @recurrenceIncrease.
  ///
  /// In ru, this message translates to:
  /// **'Увеличить'**
  String get recurrenceIncrease;

  /// No description provided for @recurrenceTooManyEvents.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много повторений. Сделайте их реже или задайте окончание'**
  String get recurrenceTooManyEvents;

  /// No description provided for @recurrenceWeekdayAbbr.
  ///
  /// In ru, this message translates to:
  /// **'{weekday, select, 1{пн} 2{вт} 3{ср} 4{чт} 5{пт} 6{сб} 7{вс} other{}}'**
  String recurrenceWeekdayAbbr(String weekday);

  /// No description provided for @recurrenceMonthAbbr.
  ///
  /// In ru, this message translates to:
  /// **'{month, select, 1{янв} 2{фев} 3{мар} 4{апр} 5{мая} 6{июн} 7{июл} 8{авг} 9{сен} 10{окт} 11{ноя} 12{дек} other{}}'**
  String recurrenceMonthAbbr(String month);

  /// No description provided for @recurrenceIntervalRowDay.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{Каждый {n} день} few{Каждые {n} дня} many{Каждые {n} дней} other{Каждые {n} дня}}'**
  String recurrenceIntervalRowDay(int n);

  /// No description provided for @recurrenceIntervalRowWeek.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{Каждую {n} неделю} few{Каждые {n} недели} many{Каждые {n} недель} other{Каждые {n} недели}}'**
  String recurrenceIntervalRowWeek(int n);

  /// No description provided for @recurrenceIntervalRowMonth.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{Каждый {n} месяц} few{Каждые {n} месяца} many{Каждые {n} месяцев} other{Каждые {n} месяца}}'**
  String recurrenceIntervalRowMonth(int n);

  /// No description provided for @recurrenceIntervalRowYear.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{Каждый {n} год} few{Каждые {n} года} many{Каждые {n} лет} other{Каждые {n} года}}'**
  String recurrenceIntervalRowYear(int n);

  /// No description provided for @recurrenceIntervalSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Интервал'**
  String get recurrenceIntervalSubtitle;

  /// No description provided for @recurrenceDuringDay.
  ///
  /// In ru, this message translates to:
  /// **'В течение дня'**
  String get recurrenceDuringDay;

  /// No description provided for @recurrenceTimesSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сколько раз за день'**
  String get recurrenceTimesSubtitle;

  /// No description provided for @recurrenceAsInEvent.
  ///
  /// In ru, this message translates to:
  /// **'Как в событии'**
  String get recurrenceAsInEvent;

  /// No description provided for @recurrenceEventTimeHint.
  ///
  /// In ru, this message translates to:
  /// **'Это время события — если поменять его здесь, оно поменяется и там'**
  String get recurrenceEventTimeHint;

  /// No description provided for @recurrenceTimeFromEvent.
  ///
  /// In ru, this message translates to:
  /// **'В {time} — время из события'**
  String recurrenceTimeFromEvent(String time);

  /// No description provided for @recurrenceWeekDaysLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели'**
  String get recurrenceWeekDaysLabel;

  /// No description provided for @recurrenceMonthDaysLabel.
  ///
  /// In ru, this message translates to:
  /// **'Числа месяца'**
  String get recurrenceMonthDaysLabel;

  /// No description provided for @recurrenceYearDatesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Даты в году'**
  String get recurrenceYearDatesLabel;

  /// No description provided for @recurrenceMonthPickHint.
  ///
  /// In ru, this message translates to:
  /// **'Выберите одно или несколько чисел'**
  String get recurrenceMonthPickHint;

  /// No description provided for @recurrenceCollapse.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть'**
  String get recurrenceCollapse;

  /// No description provided for @recurrenceEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get recurrenceEdit;

  /// No description provided for @recurrenceMonthExamplesFeb.
  ///
  /// In ru, this message translates to:
  /// **'28 февраля'**
  String get recurrenceMonthExamplesFeb;

  /// No description provided for @recurrenceMonthExamplesNovFeb.
  ///
  /// In ru, this message translates to:
  /// **'30 ноября и 28 февраля'**
  String get recurrenceMonthExamplesNovFeb;

  /// No description provided for @recurrenceAddDateRow.
  ///
  /// In ru, this message translates to:
  /// **'Добавить дату'**
  String get recurrenceAddDateRow;

  /// No description provided for @recurrenceNewDate.
  ///
  /// In ru, this message translates to:
  /// **'Новая дата'**
  String get recurrenceNewDate;

  /// No description provided for @recurrenceDateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get recurrenceDateTitle;

  /// No description provided for @recurrenceEndDateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дата окончания'**
  String get recurrenceEndDateTitle;

  /// No description provided for @recurrenceEndValueUntil.
  ///
  /// In ru, this message translates to:
  /// **'До {date}'**
  String recurrenceEndValueUntil(String date);

  /// No description provided for @recurrenceEndValueAfter.
  ///
  /// In ru, this message translates to:
  /// **'{n, plural, one{После {n} повторения} other{После {n} повторений}}'**
  String recurrenceEndValueAfter(int n);

  /// No description provided for @recurrenceEndCountLabel.
  ///
  /// In ru, this message translates to:
  /// **'Число повторений'**
  String get recurrenceEndCountLabel;

  /// No description provided for @recurrenceDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get recurrenceDelete;

  /// No description provided for @recurrenceApply.
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get recurrenceApply;

  /// No description provided for @recurrenceAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get recurrenceAdd;

  /// No description provided for @recurrenceSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get recurrenceSave;

  /// No description provided for @recurrenceBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get recurrenceBack;

  /// No description provided for @recurrenceIntervalRowDayOne.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get recurrenceIntervalRowDayOne;

  /// No description provided for @recurrenceIntervalRowWeekOne.
  ///
  /// In ru, this message translates to:
  /// **'Каждую неделю'**
  String get recurrenceIntervalRowWeekOne;

  /// No description provided for @recurrenceIntervalRowMonthOne.
  ///
  /// In ru, this message translates to:
  /// **'Каждый месяц'**
  String get recurrenceIntervalRowMonthOne;

  /// No description provided for @recurrenceIntervalRowYearOne.
  ///
  /// In ru, this message translates to:
  /// **'Каждый год'**
  String get recurrenceIntervalRowYearOne;

  /// No description provided for @profileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profileTitle;

  /// No description provided for @profileNamePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Ваше имя'**
  String get profileNamePlaceholder;

  /// No description provided for @profileEditCaption.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать профиль'**
  String get profileEditCaption;

  /// No description provided for @profileAddPhotoCaption.
  ///
  /// In ru, this message translates to:
  /// **'Добавить фото'**
  String get profileAddPhotoCaption;

  /// No description provided for @profileMyPets.
  ///
  /// In ru, this message translates to:
  /// **'Мои питомцы'**
  String get profileMyPets;

  /// No description provided for @profileSectionApp.
  ///
  /// In ru, this message translates to:
  /// **'Приложение'**
  String get profileSectionApp;

  /// No description provided for @profileSectionSupport.
  ///
  /// In ru, this message translates to:
  /// **'Поддержка'**
  String get profileSectionSupport;

  /// No description provided for @profileTheme.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get profileTheme;

  /// No description provided for @profileThemeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлое'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмное'**
  String get profileThemeDark;

  /// No description provided for @profileThemeSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системное'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeSystemHint.
  ///
  /// In ru, this message translates to:
  /// **'Как в настройках телефона: днём светлое, ночью тёмное, если так настроено'**
  String get profileThemeSystemHint;

  /// No description provided for @profileNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get profileNotifications;

  /// No description provided for @profileNotificationsAllOn.
  ///
  /// In ru, this message translates to:
  /// **'Включены'**
  String get profileNotificationsAllOn;

  /// No description provided for @profileNotificationsAllOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключены'**
  String get profileNotificationsAllOff;

  /// No description provided for @profileNotificationsBlocked.
  ///
  /// In ru, this message translates to:
  /// **'Отключены в системе'**
  String get profileNotificationsBlocked;

  /// No description provided for @profileNotificationsPartial.
  ///
  /// In ru, this message translates to:
  /// **'{enabled} из {total}'**
  String profileNotificationsPartial(int enabled, int total);

  /// No description provided for @profileHelp.
  ///
  /// In ru, this message translates to:
  /// **'Помощь и обратная связь'**
  String get profileHelp;

  /// No description provided for @profileAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get profileAbout;

  /// No description provided for @profileLogout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get profileLogout;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта?'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutMessage.
  ///
  /// In ru, this message translates to:
  /// **'Питомцы и события останутся в аккаунте. Чтобы вернуться к ним, войдите снова по номеру {phone}.'**
  String profileLogoutMessage(String phone);

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get profileLogoutConfirm;

  /// No description provided for @editProfileTitle.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get editProfileTitle;

  /// No description provided for @editProfileSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get editProfileSave;

  /// No description provided for @editProfileNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get editProfileNameLabel;

  /// No description provided for @editProfileNamePlaceholder.
  ///
  /// In ru, this message translates to:
  /// **'Как к вам обращаться'**
  String get editProfileNamePlaceholder;

  /// No description provided for @editProfilePhoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Номер телефона'**
  String get editProfilePhoneLabel;

  /// No description provided for @editProfilePhoneHint.
  ///
  /// In ru, this message translates to:
  /// **'По этому номеру вы входите в приложение'**
  String get editProfilePhoneHint;

  /// No description provided for @editProfilePhotoAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить фото'**
  String get editProfilePhotoAdd;

  /// No description provided for @editProfilePhotoChange.
  ///
  /// In ru, this message translates to:
  /// **'Изменить фото'**
  String get editProfilePhotoChange;

  /// No description provided for @editProfileInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить: проверьте имя и фото.'**
  String get editProfileInvalid;

  /// No description provided for @editProfileAccountSection.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get editProfileAccountSection;

  /// No description provided for @editProfileDeleteAccount.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get editProfileDeleteAccount;

  /// No description provided for @editProfileDeleteAccountHint.
  ///
  /// In ru, this message translates to:
  /// **'Вместе с питомцами и событиями'**
  String get editProfileDeleteAccountHint;

  /// No description provided for @profilePhotoSheetTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фото профиля'**
  String get profilePhotoSheetTitle;

  /// No description provided for @profilePhotoCamera.
  ///
  /// In ru, this message translates to:
  /// **'Сделать фото'**
  String get profilePhotoCamera;

  /// No description provided for @profilePhotoGallery.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать из галереи'**
  String get profilePhotoGallery;

  /// No description provided for @profilePhotoDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить фото'**
  String get profilePhotoDelete;

  /// No description provided for @notificationsSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notificationsSettingsTitle;

  /// No description provided for @notificationsSettingsIntro.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания приходят о делах из календаря. Выберите, о чём напомнить.'**
  String get notificationsSettingsIntro;

  /// No description provided for @notificationsSettingsSection.
  ///
  /// In ru, this message translates to:
  /// **'Напоминать о'**
  String get notificationsSettingsSection;

  /// No description provided for @notificationsSettingsFooter.
  ///
  /// In ru, this message translates to:
  /// **'Когда именно напомнить, задаётся в самом событии.'**
  String get notificationsSettingsFooter;

  /// No description provided for @notificationsSettingsFooterBlocked.
  ///
  /// In ru, this message translates to:
  /// **'Ваш выбор сохранится и заработает, как только уведомления будут разрешены.'**
  String get notificationsSettingsFooterBlocked;

  /// No description provided for @notificationWalks.
  ///
  /// In ru, this message translates to:
  /// **'Прогулки'**
  String get notificationWalks;

  /// No description provided for @notificationFeeding.
  ///
  /// In ru, this message translates to:
  /// **'Кормление'**
  String get notificationFeeding;

  /// No description provided for @notificationMedications.
  ///
  /// In ru, this message translates to:
  /// **'Лекарства'**
  String get notificationMedications;

  /// No description provided for @notificationVaccinations.
  ///
  /// In ru, this message translates to:
  /// **'Прививки'**
  String get notificationVaccinations;

  /// No description provided for @notificationVetVisits.
  ///
  /// In ru, this message translates to:
  /// **'Визиты к врачу'**
  String get notificationVetVisits;

  /// No description provided for @notificationsBlockedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления отключены в настройках устройства'**
  String get notificationsBlockedTitle;

  /// No description provided for @notificationsBlockedText.
  ///
  /// In ru, this message translates to:
  /// **'Пока они выключены, Хвостики не смогут напомнить о прогулках и лекарствах.'**
  String get notificationsBlockedText;

  /// No description provided for @notificationsBlockedAction.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get notificationsBlockedAction;

  /// No description provided for @inboxTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get inboxTitle;

  /// No description provided for @inboxFilterAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get inboxFilterAll;

  /// No description provided for @inboxFilterUnread.
  ///
  /// In ru, this message translates to:
  /// **'Непрочитанные'**
  String get inboxFilterUnread;

  /// Чип фильтра непрочитанных уведомлений с их числом
  ///
  /// In ru, this message translates to:
  /// **'Непрочитанные · {count}'**
  String inboxFilterUnreadCount(int count);

  /// No description provided for @inboxReadAll.
  ///
  /// In ru, this message translates to:
  /// **'Прочитать все'**
  String get inboxReadAll;

  /// No description provided for @inboxSectionToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get inboxSectionToday;

  /// No description provided for @inboxSectionYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get inboxSectionYesterday;

  /// No description provided for @inboxSectionEarlier.
  ///
  /// In ru, this message translates to:
  /// **'Ранее'**
  String get inboxSectionEarlier;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет уведомлений'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptyMessage.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся напоминания о лекарствах, прививках, кормлении и других делах ваших питомцев.'**
  String get inboxEmptyMessage;

  /// No description provided for @inboxEmptyAction.
  ///
  /// In ru, this message translates to:
  /// **'Настроить уведомления'**
  String get inboxEmptyAction;

  /// No description provided for @inboxAllReadTitle.
  ///
  /// In ru, this message translates to:
  /// **'Всё прочитано'**
  String get inboxAllReadTitle;

  /// No description provided for @inboxAllReadMessage.
  ///
  /// In ru, this message translates to:
  /// **'Новых уведомлений пока нет. Вся история — во вкладке «Все».'**
  String get inboxAllReadMessage;

  /// Сколько минут назад пришло уведомление
  ///
  /// In ru, this message translates to:
  /// **'{count} мин'**
  String inboxTimeMinutes(int count);

  /// Сколько часов назад пришло уведомление
  ///
  /// In ru, this message translates to:
  /// **'{count} ч'**
  String inboxTimeHours(int count);

  /// No description provided for @inboxItemNewSemantics.
  ///
  /// In ru, this message translates to:
  /// **'Новое'**
  String get inboxItemNewSemantics;

  /// Подпись колокольчика для скринридера, когда есть непрочитанные
  ///
  /// In ru, this message translates to:
  /// **'Уведомления, непрочитанных: {count}'**
  String notificationsUnreadLabel(int count);

  /// No description provided for @aboutTitle.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version} · сборка {build}'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutDescription.
  ///
  /// In ru, this message translates to:
  /// **'Профили питомцев, календарь заботы и напоминания — всё о ваших животных в одном месте.'**
  String get aboutDescription;

  /// No description provided for @aboutDocumentsSection.
  ///
  /// In ru, this message translates to:
  /// **'Документы'**
  String get aboutDocumentsSection;

  /// No description provided for @aboutTerms.
  ///
  /// In ru, this message translates to:
  /// **'Условия использования'**
  String get aboutTerms;

  /// No description provided for @aboutPrivacy.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get aboutPrivacy;

  /// No description provided for @aboutCopyright.
  ///
  /// In ru, this message translates to:
  /// **'© {year} Хвостики'**
  String aboutCopyright(int year);

  /// No description provided for @aboutDocumentSoon.
  ///
  /// In ru, this message translates to:
  /// **'Документ скоро появится'**
  String get aboutDocumentSoon;

  /// No description provided for @aboutDocumentOpenError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть документ'**
  String get aboutDocumentOpenError;

  /// No description provided for @helpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Помощь и обратная связь'**
  String get helpTitle;

  /// No description provided for @helpSubtitle.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение прочитает команда Хвостиков'**
  String get helpSubtitle;

  /// No description provided for @helpTopicProblem.
  ///
  /// In ru, this message translates to:
  /// **'Сообщить о проблеме'**
  String get helpTopicProblem;

  /// No description provided for @helpTopicProblemHint.
  ///
  /// In ru, this message translates to:
  /// **'Что-то работает не так'**
  String get helpTopicProblemHint;

  /// No description provided for @helpTopicIdea.
  ///
  /// In ru, this message translates to:
  /// **'Предложить идею'**
  String get helpTopicIdea;

  /// No description provided for @helpTopicIdeaHint.
  ///
  /// In ru, this message translates to:
  /// **'Чего не хватает в приложении'**
  String get helpTopicIdeaHint;

  /// No description provided for @helpTopicQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Задать вопрос'**
  String get helpTopicQuestion;

  /// No description provided for @helpTopicQuestionHint.
  ///
  /// In ru, this message translates to:
  /// **'Как что-то сделать в приложении'**
  String get helpTopicQuestionHint;

  /// No description provided for @feedbackTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обратная связь'**
  String get feedbackTitle;

  /// No description provided for @feedbackTopicLabel.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get feedbackTopicLabel;

  /// No description provided for @feedbackTopicProblem.
  ///
  /// In ru, this message translates to:
  /// **'Проблема'**
  String get feedbackTopicProblem;

  /// No description provided for @feedbackTopicIdea.
  ///
  /// In ru, this message translates to:
  /// **'Идея'**
  String get feedbackTopicIdea;

  /// No description provided for @feedbackTopicQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Вопрос'**
  String get feedbackTopicQuestion;

  /// No description provided for @feedbackMessageLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение'**
  String get feedbackMessageLabel;

  /// No description provided for @feedbackPlaceholderProblem.
  ///
  /// In ru, this message translates to:
  /// **'Опишите, что пошло не так'**
  String get feedbackPlaceholderProblem;

  /// No description provided for @feedbackPlaceholderIdea.
  ///
  /// In ru, this message translates to:
  /// **'Что хотелось бы добавить или изменить'**
  String get feedbackPlaceholderIdea;

  /// No description provided for @feedbackPlaceholderQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Опишите, что хотите сделать'**
  String get feedbackPlaceholderQuestion;

  /// No description provided for @feedbackScreenshotAdd.
  ///
  /// In ru, this message translates to:
  /// **'Прикрепить скриншот'**
  String get feedbackScreenshotAdd;

  /// No description provided for @feedbackScreenshotRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать скриншот'**
  String get feedbackScreenshotRemove;

  /// No description provided for @feedbackDeviceNotePrefix.
  ///
  /// In ru, this message translates to:
  /// **'Вместе с сообщением отправим версию приложения '**
  String get feedbackDeviceNotePrefix;

  /// No description provided for @feedbackDeviceNoteSuffix.
  ///
  /// In ru, this message translates to:
  /// **' и модель телефона — так мы быстрее разберёмся.'**
  String get feedbackDeviceNoteSuffix;

  /// No description provided for @feedbackSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get feedbackSend;

  /// No description provided for @feedbackSent.
  ///
  /// In ru, this message translates to:
  /// **'Спасибо! Мы получили ваше обращение.'**
  String get feedbackSent;

  /// No description provided for @feedbackRateLimit.
  ///
  /// In ru, this message translates to:
  /// **'Вы отправляете обращения слишком часто. Попробуйте чуть позже.'**
  String get feedbackRateLimit;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удаление аккаунта'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountHeadline.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт навсегда?'**
  String get deleteAccountHeadline;

  /// No description provided for @deleteAccountLead.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить данные после удаления будет нельзя — ни нам, ни вам.'**
  String get deleteAccountLead;

  /// No description provided for @deleteAccountWhatSection.
  ///
  /// In ru, this message translates to:
  /// **'Что удалится'**
  String get deleteAccountWhatSection;

  /// No description provided for @deleteAccountItemProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get deleteAccountItemProfile;

  /// No description provided for @deleteAccountItemProfileHint.
  ///
  /// In ru, this message translates to:
  /// **'Имя, фото и номер {phone}'**
  String deleteAccountItemProfileHint(String phone);

  /// No description provided for @deleteAccountItemPetsHint.
  ///
  /// In ru, this message translates to:
  /// **'{names}: фото, вес, здоровье'**
  String deleteAccountItemPetsHint(String names);

  /// No description provided for @deleteAccountNamesJoiner.
  ///
  /// In ru, this message translates to:
  /// **' и '**
  String get deleteAccountNamesJoiner;

  /// No description provided for @deleteAccountItemEvents.
  ///
  /// In ru, this message translates to:
  /// **'Календарь'**
  String get deleteAccountItemEvents;

  /// No description provided for @deleteAccountItemEventsHint.
  ///
  /// In ru, this message translates to:
  /// **'Все события и напоминания'**
  String get deleteAccountItemEventsHint;

  /// No description provided for @deleteAccountPauseHintPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Хотите просто сделать перерыв? '**
  String get deleteAccountPauseHintPrefix;

  /// No description provided for @deleteAccountPauseHintLink.
  ///
  /// In ru, this message translates to:
  /// **'Выйдите из аккаунта'**
  String get deleteAccountPauseHintLink;

  /// No description provided for @deleteAccountPauseHintSuffix.
  ///
  /// In ru, this message translates to:
  /// **' — данные сохраняются.'**
  String get deleteAccountPauseHintSuffix;

  /// No description provided for @deleteAccountAcknowledge.
  ///
  /// In ru, this message translates to:
  /// **'Я понимаю, что это навсегда'**
  String get deleteAccountAcknowledge;

  /// No description provided for @deleteAccountAcknowledgeHint.
  ///
  /// In ru, this message translates to:
  /// **'Без этого удалить аккаунт нельзя'**
  String get deleteAccountAcknowledgeHint;

  /// No description provided for @deleteAccountContinue.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get deleteAccountContinue;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите удаление'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmLead.
  ///
  /// In ru, this message translates to:
  /// **'Мы позвонили на {phone}. Введите код из звонка. Это последний шаг — после него аккаунт удалится.'**
  String deleteAccountConfirmLead(String phone);

  /// No description provided for @deleteAccountCodeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Код из звонка'**
  String get deleteAccountCodeLabel;

  /// No description provided for @deleteAccountCodeInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Неверный код. Попробуйте ещё раз.'**
  String get deleteAccountCodeInvalid;

  /// No description provided for @deleteAccountCodeTooSoon.
  ///
  /// In ru, this message translates to:
  /// **'Код уже отправлен. Повторить можно через минуту.'**
  String get deleteAccountCodeTooSoon;

  /// No description provided for @deleteAccountResendIn.
  ///
  /// In ru, this message translates to:
  /// **'Позвонить ещё раз через {time}'**
  String deleteAccountResendIn(String time);

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аккаунт'**
  String get deleteAccountConfirm;

  /// No description provided for @accountDeletedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт удалён'**
  String get accountDeletedTitle;

  /// No description provided for @accountDeletedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Мы удалили профиль, питомцев и события. Спасибо, что были с Хвостиками.'**
  String get accountDeletedMessage;

  /// No description provided for @accountDeletedButton.
  ///
  /// In ru, this message translates to:
  /// **'Вернуться ко входу'**
  String get accountDeletedButton;
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
