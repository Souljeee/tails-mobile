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

  @override
  String get monday => 'Пн';

  @override
  String get tuesday => 'Вт';

  @override
  String get wednesday => 'Ср';

  @override
  String get thursday => 'Чт';

  @override
  String get friday => 'Пт';

  @override
  String get saturday => 'Сб';

  @override
  String get sunday => 'Вс';

  @override
  String get birthday => 'Дата рождения';

  @override
  String get color => 'Окрас';

  @override
  String get status => 'Статус';

  @override
  String get sterilized => 'Кастрирован';

  @override
  String get weight => 'Вес';

  @override
  String get type => 'Тип';

  @override
  String get breed => 'Порода';

  @override
  String get gender => 'Пол';

  @override
  String get male => 'Мужской';

  @override
  String get female => 'Женский';

  @override
  String get error => 'Ошибка';

  @override
  String get deletePetTitle => 'Удалить питомца';

  @override
  String get deletePetSubtitle =>
      'Вы уверены, что хотите удалить этого питомца? Это действие нельзя будет отменить.';

  @override
  String get deletePetCancel => 'Отмена';

  @override
  String get deletePetDelete => 'Удалить';

  @override
  String get all => 'Все';

  @override
  String get navPets => 'Питомцы';

  @override
  String get navCalendar => 'Календарь';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navAddPet => 'Добавить питомца';

  @override
  String get navAddEvent => 'Добавить событие';

  @override
  String get authSlide1Title => 'Профиль любимца';

  @override
  String get authSlide1Subtitle =>
      'Имя, порода, дата рождения и заметки — чтобы ничего не терялось.';

  @override
  String get authSlide2Title => 'Календарь питомца';

  @override
  String get authSlide2Subtitle => 'Все запланированные события в одном списке и по датам.';

  @override
  String get authSlide3Title => 'Ничего не забыть';

  @override
  String get authSlide3Subtitle =>
      'Создавайте напоминания о важных делах для питомца за пару секунд.';

  @override
  String get authPhoneTitle => 'Введите ваш номер телефона';

  @override
  String get authPhoneSubtitle => 'Мы отправим вам безопасный код подтверждения';

  @override
  String get authPhoneLabel => 'Номер телефона';

  @override
  String get authGetCode => 'Получить код';

  @override
  String get authConsentPrefix => 'Нажимая «Получить код», вы соглашаетесь с нашими ';

  @override
  String get authTerms => 'Условиями использования';

  @override
  String get authConsentAnd => ' и ';

  @override
  String get authPrivacy => 'Политикой конфиденциальности';

  @override
  String get enterCodeBack => 'Назад';

  @override
  String enterCodeDigitLabel(int index, int count) {
    return 'Цифра $index из $count';
  }

  @override
  String get scheduleToday => 'Сегодня';

  @override
  String scheduleTodayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дела на сегодня',
      many: '$count дел на сегодня',
      few: '$count дела на сегодня',
      one: '$count дело на сегодня',
      zero: 'Нет дел на сегодня',
    );
    return '$_temp0';
  }

  @override
  String scheduleEventsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count события',
      many: '$count событий',
      few: '$count события',
      one: '$count событие',
      zero: 'Нет событий',
    );
    return '$_temp0';
  }

  @override
  String get scheduleAllDay => 'Весь день';

  @override
  String get scheduleEmptyDay => 'На этот день событий нет';

  @override
  String get schedulePreviousMonth => 'Предыдущий месяц';

  @override
  String get scheduleNextMonth => 'Следующий месяц';

  @override
  String get fetchingErrorTitle => 'Ошибка загрузки';

  @override
  String get fetchingErrorMessage => 'Повторите позднее';

  @override
  String get fetchingErrorRetry => 'Повторить';

  @override
  String get eventTypeDeworming => 'Дегельминтизация';

  @override
  String get eventTypeYearlyVaccination => 'Годовая вакцинация';

  @override
  String get eventTypeRabiesVaccination => 'Вакцинация от бешенства';

  @override
  String get eventTypeWeeklyPills => 'Недельные таблетки';

  @override
  String get eventTypeDailyPills => 'Лекарства';

  @override
  String get eventTypeGrooming => 'Уход за шерстью';

  @override
  String get eventTypeBathing => 'Купание';

  @override
  String get eventTypeWalking => 'Прогулка';

  @override
  String get eventTypeFeeding => 'Кормление';

  @override
  String get eventTypeNailTrimming => 'Стрижка когтей';

  @override
  String get eventTypeFleaTreatment => 'Обработка от блох';

  @override
  String get eventTypeCustom => 'Другое';
}
