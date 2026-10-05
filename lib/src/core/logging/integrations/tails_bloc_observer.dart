import 'package:bloc/bloc.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

/// Пишет в журнал события, переходы и ошибки всех Bloc.
///
/// В журнал попадают только имена типов (`FetchRequested`, `Loading → Success`), но не
/// содержимое событий и состояний: оно может включать персональные данные.
/// Устанавливается глобально: `Bloc.observer = const TailsBlocObserver()`.
final class TailsBlocObserver extends BlocObserver {
  /// Создаёт наблюдатель.
  const TailsBlocObserver();

  @override
  void onEvent(Bloc<Object?, Object?> bloc, Object? event) {
    super.onEvent(bloc, event);

    TailsLogger.debug(
      '⇢ ${_shortName(event)}',
      category: TailsLogCategory.bloc,
      source: _name(bloc),
    );
  }

  @override
  void onTransition(Bloc<Object?, Object?> bloc, Transition<Object?, Object?> transition) {
    super.onTransition(bloc, transition);

    TailsLogger.debug(
      '${_shortName(transition.currentState)} → ${_shortName(transition.nextState)} '
      '‹${_shortName(transition.event)}›',
      category: TailsLogCategory.bloc,
      source: _name(bloc),
    );
  }

  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    TailsLogger.error(
      'Ошибка',
      category: TailsLogCategory.bloc,
      source: _name(bloc),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static String _name(Object? object) => '${object.runtimeType}';

  /// Имя типа без префикса sealed-класса: `PetDetailsState$Loading` → `Loading`.
  static String _shortName(Object? object) {
    final name = _name(object);
    final separator = name.lastIndexOf(r'$');

    return separator == -1 ? name : name.substring(separator + 1);
  }
}
