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
  String get eventTypeVetVisit => 'Визит к ветеринару';

  @override
  String get eventTypeCustom => 'Другое';

  @override
  String get cancel => 'Отмена';

  @override
  String get createEventTitle => 'Новое событие';

  @override
  String get createEventForWhom => 'Для кого';

  @override
  String get createEventNameLabel => 'Название';

  @override
  String get createEventNamePlaceholder => 'Например, «Покормить кота»';

  @override
  String get createEventTypeLabel => 'Тип';

  @override
  String get createEventDateLabel => 'Дата';

  @override
  String get createEventDatePlaceholder => 'ДД.ММ.ГГГГ';

  @override
  String get createEventTimeLabel => 'Время';

  @override
  String get createEventTimePlaceholder => 'чч:мм';

  @override
  String get createEventRecurrenceLabel => 'Повторение';

  @override
  String get createEventNoRecurrence => 'Не повторять';

  @override
  String get createEventNotesLabel => 'Заметки · необязательно';

  @override
  String get createEventNotesPlaceholder => 'Добавьте детали...';

  @override
  String get createEventSubmit => 'Создать событие';

  @override
  String get eventChipTime => 'Время';

  @override
  String get timePickerClear => 'Очистить';

  @override
  String get petsOverviewTitle => 'Мои питомцы';

  @override
  String petsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count питомца',
      many: '$count питомцев',
      few: '$count питомца',
      one: '$count питомец',
    );
    return '$_temp0';
  }

  @override
  String petsTodayEvents(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'сегодня $count дела',
      many: 'сегодня $count дел',
      few: 'сегодня $count дела',
      one: 'сегодня $count дело',
      zero: 'сегодня дел нет',
    );
    return '$_temp0';
  }

  @override
  String get petsEmptyTitle => 'Список ваших питомцев пуст';

  @override
  String get petsEmptyMessage => 'Расскажите нам о ваших любимцах';

  @override
  String get notificationsLabel => 'Уведомления';

  @override
  String petAgeShortYearsMonths(int years, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      years,
      locale: localeName,
      other: '$years лет',
      many: '$years лет',
      few: '$years года',
      one: '$years год',
    );
    return '$_temp0 $months мес.';
  }

  @override
  String petAgeShortMonths(int months) {
    return '$months мес.';
  }

  @override
  String petWeightKg(String weight) {
    return '$weight кг';
  }

  @override
  String get petNextEventToday => 'Сегодня';

  @override
  String get petNextEventTomorrow => 'Завтра';

  @override
  String get breedPageTitleCat => 'Порода · кошки';

  @override
  String get breedPageTitleDog => 'Порода · собаки';

  @override
  String get breedSearchPlaceholder => 'Найти породу';

  @override
  String get breedNothingFound => 'Ничего не найдено';

  @override
  String get breedMixedLabel => 'Метис или не знаю';

  @override
  String get addPetTitle => 'Новый питомец';

  @override
  String get editPetTitle => 'Изменить питомца';

  @override
  String get addPetSubmit => 'Добавить питомца';

  @override
  String get savePet => 'Сохранить';

  @override
  String get petFormMain => 'Основное';

  @override
  String get petFormDetails => 'Детали';

  @override
  String get petFormKind => 'Вид';

  @override
  String get petFormName => 'Кличка';

  @override
  String get petFormNamePlaceholder => 'Например, Барсик';

  @override
  String get petFormSex => 'Пол';

  @override
  String get petSexMale => 'Мужской';

  @override
  String get petSexFemale => 'Женский';

  @override
  String get petFormBreed => 'Порода';

  @override
  String get petFormBreedPlaceholder => 'Выберите породу';

  @override
  String get petFormBirthday => 'Дата рождения';

  @override
  String get petFormBirthdayHint => 'Если не знаете точно — укажите примерную дату';

  @override
  String get petFormWeight => 'Вес';

  @override
  String get petFormWeightPlaceholder => 'Выберите';

  @override
  String get petFormColor => 'Окрас';

  @override
  String get petFormColorPlaceholder => 'Например, рыжий';

  @override
  String get petCastratedMale => 'Кастрирован';

  @override
  String get petCastratedFemale => 'Стерилизована';

  @override
  String get petCastratedHint => 'Можно изменить позже в профиле';

  @override
  String get petPhotoAdd => 'Добавить фото';

  @override
  String get petPhotoChange => 'Изменить фото';

  @override
  String get petPhotoHint => 'Фото поможет быстрее находить питомца';

  @override
  String get photoSourceTitle => 'Загрузить фото';

  @override
  String get photoSourceGallery => 'Галерея';

  @override
  String get photoSourceCamera => 'Камера';

  @override
  String get photoPickError => 'Не удалось выбрать фото';

  @override
  String get weightKgUnit => 'кг';

  @override
  String get weightGramsUnit => 'г';

  @override
  String get done => 'Готово';

  @override
  String get selectAction => 'Выбрать';

  @override
  String get pickBirthDateTitle => 'Дата рождения';

  @override
  String get navBack => 'Назад';

  @override
  String get petDetailsMenu => 'Меню';

  @override
  String get petDetailsAge => 'Возраст';

  @override
  String get petDetailsEdit => 'Изменить';

  @override
  String get petDetailsUpcoming => 'Ближайшие события';

  @override
  String get petDetailsNoEvents => 'В ближайшие две недели событий нет';

  @override
  String get petFormErrorName => 'Введите кличку';

  @override
  String get petFormErrorBreed => 'Выберите породу';

  @override
  String get petFormErrorBirthday => 'Укажите дату рождения';

  @override
  String get petFormErrorWeight => 'Укажите вес';

  @override
  String get petFormErrorColor => 'Введите окрас';

  @override
  String get createEventErrorPet => 'Выберите питомца';

  @override
  String get createEventErrorTitle => 'Введите название';

  @override
  String get discardTitle => 'Закрыть без сохранения?';

  @override
  String get discardMessage => 'Введённые данные будут потеряны.';

  @override
  String get discardKeepEditing => 'Продолжить';

  @override
  String get discardConfirm => 'Закрыть';

  @override
  String get petsScheduleUnavailable => 'Не удалось загрузить события';

  @override
  String get recurrenceAnd => 'и';

  @override
  String get recurrenceEveryDay => 'Каждый день';

  @override
  String get recurrenceEveryOtherDay => 'Через день';

  @override
  String recurrenceEveryNDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Каждые $n дня',
      many: 'Каждые $n дней',
      few: 'Каждые $n дня',
      one: 'Каждый $n день',
    );
    return '$_temp0';
  }

  @override
  String get recurrenceWeekdays => 'По будням';

  @override
  String get recurrenceWeekends => 'По выходным';

  @override
  String recurrenceEveryWeekday(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      '1': 'Каждый понедельник',
      '2': 'Каждый вторник',
      '3': 'Каждую среду',
      '4': 'Каждый четверг',
      '5': 'Каждую пятницу',
      '6': 'Каждую субботу',
      '7': 'Каждое воскресенье',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String recurrenceWeekdayDative(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      '1': 'понедельникам',
      '2': 'вторникам',
      '3': 'средам',
      '4': 'четвергам',
      '5': 'пятницам',
      '6': 'субботам',
      '7': 'воскресеньям',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String recurrenceOnWeekdays(String days) {
    return 'По $days';
  }

  @override
  String recurrenceEveryNWeeksOn(int n, String days) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Каждые $n недели',
      many: 'Каждые $n недель',
      few: 'Каждые $n недели',
      one: 'Каждую $n неделю',
    );
    return '$_temp0 по $days';
  }

  @override
  String get recurrenceMonthEvery => 'каждого месяца';

  @override
  String recurrenceMonthEveryN(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'каждые $n месяца',
      many: 'каждые $n месяцев',
      few: 'каждые $n месяца',
      one: 'каждый $n месяц',
    );
    return '$_temp0';
  }

  @override
  String recurrenceMonthNumbers(String days, String every) {
    return '$days числа $every';
  }

  @override
  String recurrenceMonthLast(String every) {
    return 'В последний день $every';
  }

  @override
  String recurrenceMonthNumbersAndLast(String days, String every) {
    return '$days числа и в последний день $every';
  }

  @override
  String recurrenceMonthGenitive(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'января',
      '2': 'февраля',
      '3': 'марта',
      '4': 'апреля',
      '5': 'мая',
      '6': 'июня',
      '7': 'июля',
      '8': 'августа',
      '9': 'сентября',
      '10': 'октября',
      '11': 'ноября',
      '12': 'декабря',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String recurrenceDayMonth(int day, String month) {
    return '$day $month';
  }

  @override
  String recurrenceYearEvery(String dates) {
    return '$dates каждого года';
  }

  @override
  String recurrenceYearEveryN(String dates, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'каждые $n года',
      many: 'каждые $n лет',
      few: 'каждые $n года',
      one: 'каждый $n год',
    );
    return '$dates, $_temp0';
  }

  @override
  String get recurrenceOncePerWeek => 'раз в неделю';

  @override
  String get recurrenceOncePerMonth => 'раз в месяц';

  @override
  String get recurrenceOncePerYear => 'раз в год';

  @override
  String recurrenceTimesPerDay(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n раз', few: '$n раза');
    return '$_temp0 в день';
  }

  @override
  String recurrenceTimesPerWeek(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n раз', few: '$n раза');
    return '$_temp0 в неделю';
  }

  @override
  String recurrenceTimesPerMonth(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n раз', few: '$n раза');
    return '$_temp0 в месяц';
  }

  @override
  String recurrenceTimesPerYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n раз', few: '$n раза');
    return '$_temp0 в год';
  }

  @override
  String recurrenceOnceInUnits(String unit) {
    return 'раз в $unit';
  }

  @override
  String recurrenceTimesInUnits(int n, String unit) {
    String _temp0 = intl.Intl.pluralLogic(n, locale: localeName, other: '$n раз', few: '$n раза');
    return '$_temp0 за $unit';
  }

  @override
  String recurrenceUnitWeeks(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n недели',
      many: '$n недель',
      few: '$n недели',
      one: '$n неделю',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUnitMonths(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n месяца',
      many: '$n месяцев',
      few: '$n месяца',
      one: '$n месяц',
    );
    return '$_temp0';
  }

  @override
  String recurrenceUnitYears(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n года',
      many: '$n лет',
      few: '$n года',
      one: '$n год',
    );
    return '$_temp0';
  }

  @override
  String recurrenceAtTime(String time) {
    return 'в $time';
  }

  @override
  String recurrenceEndUntil(String date) {
    return 'до $date';
  }

  @override
  String recurrenceEndAfter(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n повторений',
      one: '$n повторения',
    );
    return 'после $_temp0';
  }

  @override
  String get recurrenceTitle => 'Повторение';

  @override
  String get recurrenceReset => 'Не повторять';

  @override
  String recurrenceNext(String dates) {
    return 'Ближайшие: $dates';
  }

  @override
  String get recurrencePeriodDay => 'День';

  @override
  String get recurrencePeriodWeek => 'Неделя';

  @override
  String get recurrencePeriodMonth => 'Месяц';

  @override
  String get recurrencePeriodYear => 'Год';

  @override
  String recurrenceWeekdayShort(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      '1': 'Пн',
      '2': 'Вт',
      '3': 'Ср',
      '4': 'Чт',
      '5': 'Пт',
      '6': 'Сб',
      '7': 'Вс',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get recurrencePresetWeekdays => 'Будни';

  @override
  String get recurrencePresetWeekend => 'Выходные';

  @override
  String get recurrencePresetAllDays => 'Каждый день';

  @override
  String get recurrenceLastDay => 'Последний день';

  @override
  String recurrenceMonthTransferHint(String examples) {
    return 'В коротких месяцах событие переносится на последний день — например, $examples';
  }

  @override
  String get recurrenceFeb29Hint => 'В невисокосный год событие перенесётся на 28 февраля';

  @override
  String recurrenceTimeN(int n) {
    return 'Время $n';
  }

  @override
  String get recurrenceEndTitle => 'Окончание';

  @override
  String get recurrenceEndNever => 'Без окончания';

  @override
  String get recurrenceEndOnDate => 'До определённой даты';

  @override
  String get recurrenceEndAfterCount => 'После нескольких повторений';

  @override
  String get recurrenceEndErrorBeforeStart => 'Дата окончания раньше даты события';

  @override
  String recurrenceEndErrorBeforeFirst(String date) {
    return 'Первое повторение — $date, дата окончания раньше';
  }

  @override
  String get recurrenceDecrease => 'Уменьшить';

  @override
  String get recurrenceIncrease => 'Увеличить';

  @override
  String get recurrenceTooManyEvents =>
      'Слишком много повторений. Сделайте их реже или задайте окончание';

  @override
  String recurrenceWeekdayAbbr(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      '1': 'пн',
      '2': 'вт',
      '3': 'ср',
      '4': 'чт',
      '5': 'пт',
      '6': 'сб',
      '7': 'вс',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String recurrenceMonthAbbr(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'янв',
      '2': 'фев',
      '3': 'мар',
      '4': 'апр',
      '5': 'мая',
      '6': 'июн',
      '7': 'июл',
      '8': 'авг',
      '9': 'сен',
      '10': 'окт',
      '11': 'ноя',
      '12': 'дек',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String recurrenceIntervalRowDay(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Каждые $n дня',
      many: 'Каждые $n дней',
      few: 'Каждые $n дня',
      one: 'Каждый $n день',
    );
    return '$_temp0';
  }

  @override
  String recurrenceIntervalRowWeek(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Каждые $n недели',
      many: 'Каждые $n недель',
      few: 'Каждые $n недели',
      one: 'Каждую $n неделю',
    );
    return '$_temp0';
  }

  @override
  String recurrenceIntervalRowMonth(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Каждые $n месяца',
      many: 'Каждые $n месяцев',
      few: 'Каждые $n месяца',
      one: 'Каждый $n месяц',
    );
    return '$_temp0';
  }

  @override
  String recurrenceIntervalRowYear(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Каждые $n года',
      many: 'Каждые $n лет',
      few: 'Каждые $n года',
      one: 'Каждый $n год',
    );
    return '$_temp0';
  }

  @override
  String get recurrenceIntervalSubtitle => 'Интервал';

  @override
  String get recurrenceDuringDay => 'В течение дня';

  @override
  String get recurrenceTimesSubtitle => 'Сколько раз за день';

  @override
  String get recurrenceAsInEvent => 'Как в событии';

  @override
  String get recurrenceEventTimeHint =>
      'Это время события — если поменять его здесь, оно поменяется и там';

  @override
  String recurrenceTimeFromEvent(String time) {
    return 'В $time — время из события';
  }

  @override
  String get recurrenceWeekDaysLabel => 'Дни недели';

  @override
  String get recurrenceMonthDaysLabel => 'Числа месяца';

  @override
  String get recurrenceYearDatesLabel => 'Даты в году';

  @override
  String get recurrenceMonthPickHint => 'Выберите одно или несколько чисел';

  @override
  String get recurrenceCollapse => 'Свернуть';

  @override
  String get recurrenceEdit => 'Изменить';

  @override
  String get recurrenceMonthExamplesFeb => '28 февраля';

  @override
  String get recurrenceMonthExamplesNovFeb => '30 ноября и 28 февраля';

  @override
  String get recurrenceAddDateRow => 'Добавить дату';

  @override
  String get recurrenceNewDate => 'Новая дата';

  @override
  String get recurrenceDateTitle => 'Дата';

  @override
  String get recurrenceEndDateTitle => 'Дата окончания';

  @override
  String recurrenceEndValueUntil(String date) {
    return 'До $date';
  }

  @override
  String recurrenceEndValueAfter(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'После $n повторений',
      one: 'После $n повторения',
    );
    return '$_temp0';
  }

  @override
  String get recurrenceEndCountLabel => 'Число повторений';

  @override
  String get recurrenceDelete => 'Удалить';

  @override
  String get recurrenceApply => 'Применить';

  @override
  String get recurrenceAdd => 'Добавить';

  @override
  String get recurrenceSave => 'Сохранить';

  @override
  String get recurrenceBack => 'Назад';

  @override
  String get recurrenceIntervalRowDayOne => 'Каждый день';

  @override
  String get recurrenceIntervalRowWeekOne => 'Каждую неделю';

  @override
  String get recurrenceIntervalRowMonthOne => 'Каждый месяц';

  @override
  String get recurrenceIntervalRowYearOne => 'Каждый год';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileNamePlaceholder => 'Ваше имя';

  @override
  String get profileEditCaption => 'Редактировать профиль';

  @override
  String get profileAddPhotoCaption => 'Добавить фото';

  @override
  String get profileMyPets => 'Мои питомцы';

  @override
  String get profileSectionApp => 'Приложение';

  @override
  String get profileSectionSupport => 'Поддержка';

  @override
  String get profileNotifications => 'Уведомления';

  @override
  String get profileNotificationsAllOn => 'Включены';

  @override
  String get profileNotificationsAllOff => 'Выключены';

  @override
  String get profileNotificationsBlocked => 'Отключены в системе';

  @override
  String profileNotificationsPartial(int enabled, int total) {
    return '$enabled из $total';
  }

  @override
  String get profileHelp => 'Помощь и обратная связь';

  @override
  String get profileAbout => 'О приложении';

  @override
  String get profileLogout => 'Выйти из аккаунта';

  @override
  String get profileLogoutTitle => 'Выйти из аккаунта?';

  @override
  String profileLogoutMessage(String phone) {
    return 'Питомцы и события останутся в аккаунте. Чтобы вернуться к ним, войдите снова по номеру $phone.';
  }

  @override
  String get profileLogoutConfirm => 'Выйти';

  @override
  String get editProfileTitle => 'Профиль';

  @override
  String get editProfileSave => 'Сохранить';

  @override
  String get editProfileNameLabel => 'Имя';

  @override
  String get editProfileNamePlaceholder => 'Как к вам обращаться';

  @override
  String get editProfilePhoneLabel => 'Номер телефона';

  @override
  String get editProfilePhoneHint => 'По этому номеру вы входите в приложение';

  @override
  String get editProfilePhotoAdd => 'Добавить фото';

  @override
  String get editProfilePhotoChange => 'Изменить фото';

  @override
  String get editProfileInvalid => 'Не удалось сохранить: проверьте имя и фото.';

  @override
  String get editProfileAccountSection => 'Аккаунт';

  @override
  String get editProfileDeleteAccount => 'Удалить аккаунт';

  @override
  String get editProfileDeleteAccountHint => 'Вместе с питомцами и событиями';

  @override
  String get profilePhotoSheetTitle => 'Фото профиля';

  @override
  String get profilePhotoCamera => 'Сделать фото';

  @override
  String get profilePhotoGallery => 'Выбрать из галереи';

  @override
  String get profilePhotoDelete => 'Удалить фото';

  @override
  String get notificationsSettingsTitle => 'Уведомления';

  @override
  String get notificationsSettingsIntro =>
      'Напоминания приходят о делах из календаря. Выберите, о чём напомнить.';

  @override
  String get notificationsSettingsSection => 'Напоминать о';

  @override
  String get notificationsSettingsFooter => 'Когда именно напомнить, задаётся в самом событии.';

  @override
  String get notificationsSettingsFooterBlocked =>
      'Ваш выбор сохранится и заработает, как только уведомления будут разрешены.';

  @override
  String get notificationWalks => 'Прогулки';

  @override
  String get notificationFeeding => 'Кормление';

  @override
  String get notificationMedications => 'Лекарства';

  @override
  String get notificationVaccinations => 'Прививки';

  @override
  String get notificationVetVisits => 'Визиты к врачу';

  @override
  String get notificationsBlockedTitle => 'Уведомления отключены в настройках устройства';

  @override
  String get notificationsBlockedText =>
      'Пока они выключены, Хвостики не смогут напомнить о прогулках и лекарствах.';

  @override
  String get notificationsBlockedAction => 'Открыть настройки';

  @override
  String get inboxTitle => 'Уведомления';

  @override
  String get inboxFilterAll => 'Все';

  @override
  String get inboxFilterUnread => 'Непрочитанные';

  @override
  String inboxFilterUnreadCount(int count) {
    return 'Непрочитанные · $count';
  }

  @override
  String get inboxReadAll => 'Прочитать все';

  @override
  String get inboxSectionToday => 'Сегодня';

  @override
  String get inboxSectionYesterday => 'Вчера';

  @override
  String get inboxSectionEarlier => 'Ранее';

  @override
  String get inboxEmptyTitle => 'Пока нет уведомлений';

  @override
  String get inboxEmptyMessage =>
      'Здесь появятся напоминания о лекарствах, прививках, кормлении и других делах ваших питомцев.';

  @override
  String get inboxEmptyAction => 'Настроить уведомления';

  @override
  String get inboxAllReadTitle => 'Всё прочитано';

  @override
  String get inboxAllReadMessage => 'Новых уведомлений пока нет. Вся история — во вкладке «Все».';

  @override
  String inboxTimeMinutes(int count) {
    return '$count мин';
  }

  @override
  String inboxTimeHours(int count) {
    return '$count ч';
  }

  @override
  String get inboxItemNewSemantics => 'Новое';

  @override
  String notificationsUnreadLabel(int count) {
    return 'Уведомления, непрочитанных: $count';
  }

  @override
  String get aboutTitle => 'О приложении';

  @override
  String aboutVersion(String version, String build) {
    return 'Версия $version · сборка $build';
  }

  @override
  String get aboutDescription =>
      'Профили питомцев, календарь заботы и напоминания — всё о ваших животных в одном месте.';

  @override
  String get aboutDocumentsSection => 'Документы';

  @override
  String get aboutTerms => 'Условия использования';

  @override
  String get aboutPrivacy => 'Политика конфиденциальности';

  @override
  String aboutCopyright(int year) {
    return '© $year Хвостики';
  }

  @override
  String get aboutDocumentSoon => 'Документ скоро появится';

  @override
  String get aboutDocumentOpenError => 'Не удалось открыть документ';

  @override
  String get helpTitle => 'Помощь и обратная связь';

  @override
  String get helpSubtitle => 'Сообщение прочитает команда Хвостиков';

  @override
  String get helpTopicProblem => 'Сообщить о проблеме';

  @override
  String get helpTopicProblemHint => 'Что-то работает не так';

  @override
  String get helpTopicIdea => 'Предложить идею';

  @override
  String get helpTopicIdeaHint => 'Чего не хватает в приложении';

  @override
  String get helpTopicQuestion => 'Задать вопрос';

  @override
  String get helpTopicQuestionHint => 'Как что-то сделать в приложении';

  @override
  String get feedbackTitle => 'Обратная связь';

  @override
  String get feedbackTopicLabel => 'Тема';

  @override
  String get feedbackTopicProblem => 'Проблема';

  @override
  String get feedbackTopicIdea => 'Идея';

  @override
  String get feedbackTopicQuestion => 'Вопрос';

  @override
  String get feedbackMessageLabel => 'Сообщение';

  @override
  String get feedbackPlaceholderProblem => 'Опишите, что пошло не так';

  @override
  String get feedbackPlaceholderIdea => 'Что хотелось бы добавить или изменить';

  @override
  String get feedbackPlaceholderQuestion => 'Опишите, что хотите сделать';

  @override
  String get feedbackScreenshotAdd => 'Прикрепить скриншот';

  @override
  String get feedbackScreenshotRemove => 'Убрать скриншот';

  @override
  String get feedbackDeviceNotePrefix => 'Вместе с сообщением отправим версию приложения ';

  @override
  String get feedbackDeviceNoteSuffix => ' и модель телефона — так мы быстрее разберёмся.';

  @override
  String get feedbackSend => 'Отправить';

  @override
  String get feedbackSent => 'Спасибо! Мы получили ваше обращение.';

  @override
  String get feedbackRateLimit => 'Вы отправляете обращения слишком часто. Попробуйте чуть позже.';

  @override
  String get deleteAccountTitle => 'Удаление аккаунта';

  @override
  String get deleteAccountHeadline => 'Удалить аккаунт навсегда?';

  @override
  String get deleteAccountLead =>
      'Восстановить данные после удаления будет нельзя — ни нам, ни вам.';

  @override
  String get deleteAccountWhatSection => 'Что удалится';

  @override
  String get deleteAccountItemProfile => 'Профиль';

  @override
  String deleteAccountItemProfileHint(String phone) {
    return 'Имя, фото и номер $phone';
  }

  @override
  String deleteAccountItemPetsHint(String names) {
    return '$names: фото, вес, здоровье';
  }

  @override
  String get deleteAccountNamesJoiner => ' и ';

  @override
  String get deleteAccountItemEvents => 'Календарь';

  @override
  String get deleteAccountItemEventsHint => 'Все события и напоминания';

  @override
  String get deleteAccountPauseHintPrefix => 'Хотите просто сделать перерыв? ';

  @override
  String get deleteAccountPauseHintLink => 'Выйдите из аккаунта';

  @override
  String get deleteAccountPauseHintSuffix => ' — данные сохраняются.';

  @override
  String get deleteAccountAcknowledge => 'Я понимаю, что это навсегда';

  @override
  String get deleteAccountAcknowledgeHint => 'Без этого удалить аккаунт нельзя';

  @override
  String get deleteAccountContinue => 'Продолжить';

  @override
  String get deleteAccountConfirmTitle => 'Подтвердите удаление';

  @override
  String deleteAccountConfirmLead(String phone) {
    return 'Мы позвонили на $phone. Введите код из звонка. Это последний шаг — после него аккаунт удалится.';
  }

  @override
  String get deleteAccountCodeLabel => 'Код из звонка';

  @override
  String get deleteAccountCodeInvalid => 'Неверный код. Попробуйте ещё раз.';

  @override
  String get deleteAccountCodeTooSoon => 'Код уже отправлен. Повторить можно через минуту.';

  @override
  String deleteAccountResendIn(String time) {
    return 'Позвонить ещё раз через $time';
  }

  @override
  String get deleteAccountConfirm => 'Удалить аккаунт';

  @override
  String get accountDeletedTitle => 'Аккаунт удалён';

  @override
  String get accountDeletedMessage =>
      'Мы удалили профиль, питомцев и события. Спасибо, что были с Хвостиками.';

  @override
  String get accountDeletedButton => 'Вернуться ко входу';
}
