import 'dart:async';
import 'dart:math';

/// Состояние приложения, которое добавляется в записи журнала.
///
/// Здесь хранятся идентификатор запуска и текущий экран. Идентификатор запуска попадает в
/// запись о старте и в заголовок файла журнала, чтобы по присланному журналу было видно, к
/// какому запуску он относится. Текущий экран обновляет `NavigationLogger`, а сетевые записи
/// подписываются им (`screen=pets`): видно, с какого экрана ушёл запрос.
abstract final class TailsLogContext {
  /// Идентификатор текущего запуска или `null`, пока запуск не начат.
  static String? sessionId;

  /// Имя текущего экрана (имя маршрута) или `null`, пока навигация не началась.
  static String? screen;

  static const Symbol _originKey = #tailsLogOrigin;

  /// Кто сейчас выполняет работу: идентификатор BLoC, обрабатывающего событие
  /// (`PetDetailsBloc#a3`), или `null`, если работа не связана с BLoC.
  ///
  /// Значение хранится в зоне, поэтому переживает `await` и доступно во всём асинхронном
  /// коде, который запустил обработчик события: сетевой слой подписывает им запросы
  /// (`bloc=PetDetailsBloc#a3`) и по журналу видно, какое событие вызвало запрос.
  static String? get origin => Zone.current[_originKey] as String?;

  /// Выполняет [body] в зоне, где [origin] равен [value].
  static T runWithOrigin<T>(String value, T Function() body) =>
      runZoned(body, zoneValues: {_originKey: value});

  static String? _creating;

  /// BLoC, который создаётся прямо сейчас, или `null`.
  ///
  /// `BlocObserver.onCreate` вызывается в конструкторе базового класса, до того как
  /// наследник регистрирует обработчики (`on<Event>`). Поэтому транслятор событий в момент
  /// регистрации видит именно свой BLoC. Привязка к самому событию не годится:
  /// `const`-события — один и тот же объект у разных BLoC.
  static String? get creatingBloc => _creating;

  /// Отмечает BLoC, который создаётся. Сбрасывается сам, как только завершится
  /// синхронный код конструктора.
  static void markBlocCreating(String value) {
    _creating = value;
    scheduleMicrotask(() {
      if (_creating == value) _creating = null;
    });
  }

  /// Начинает новый запуск: создаёт короткий случайный идентификатор (например, `8f2c41a7`).
  ///
  /// [random] нужен тестам, чтобы получить предсказуемое значение.
  static String startSession({Random? random}) {
    final value = (random ?? Random()).nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
    sessionId = value;

    return value;
  }

  /// Сбрасывает контекст (для тестов).
  static void reset() {
    sessionId = null;
    screen = null;
    _creating = null;
  }
}
