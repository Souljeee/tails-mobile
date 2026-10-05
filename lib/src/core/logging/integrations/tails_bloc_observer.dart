import 'package:bloc/bloc.dart';
import 'package:tails_mobile/src/core/logging/tails_log_context.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_loggable.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

/// Пишет в журнал жизненный цикл, события, переходы и ошибки всех Bloc и Cubit.
///
/// Каждый экземпляр получает короткий идентификатор (`PetDetailsBloc#a3`), чтобы в журнале
/// различать несколько блоков одного типа. В записи попадают только имена типов
/// (`Loading → Success ‹FetchRequested›`), но не содержимое событий и состояний: оно может
/// включать персональные данные. Содержимое добавляется точечно через [TailsLoggable].
///
/// Устанавливается глобально: `Bloc.observer = const TailsBlocObserver()`.
final class TailsBlocObserver extends BlocObserver {
  /// Создаёт наблюдатель.
  const TailsBlocObserver();

  static final Expando<String> _ids = Expando<String>('TailsBlocObserver.ids');
  static int _counter = 0;

  @override
  void onCreate(BlocBase<Object?> bloc) {
    super.onCreate(bloc);

    TailsLogContext.markBlocCreating(_id(bloc));
    _log('создан', bloc);
  }

  @override
  void onEvent(Bloc<Object?, Object?> bloc, Object? event) {
    super.onEvent(bloc, event);

    _log('⇢ ${_shortName(event)}', bloc, data: _data(event: event));
  }

  @override
  void onChange(BlocBase<Object?> bloc, Change<Object?> change) {
    super.onChange(bloc, change);

    // У Bloc переход описывает onTransition (в нём есть событие), поэтому здесь — только Cubit.
    if (bloc is Bloc<Object?, Object?>) return;

    _log(
      '${_shortName(change.currentState)} → ${_shortName(change.nextState)}',
      bloc,
      data: _data(state: change.nextState),
    );
  }

  @override
  void onTransition(Bloc<Object?, Object?> bloc, Transition<Object?, Object?> transition) {
    super.onTransition(bloc, transition);

    _log(
      '${_shortName(transition.currentState)} → ${_shortName(transition.nextState)} '
      '‹${_shortName(transition.event)}›',
      bloc,
      data: _data(event: transition.event, state: transition.nextState),
    );
  }

  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);

    TailsLogger.error(
      'Ошибка',
      category: TailsLogCategory.bloc,
      source: _id(bloc),
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase<Object?> bloc) {
    super.onClose(bloc);

    _log('закрыт', bloc);
  }

  static void _log(String message, BlocBase<Object?> bloc, {Map<String, Object?>? data}) {
    TailsLogger.debug(message, category: TailsLogCategory.bloc, source: _id(bloc), data: data);
  }

  /// Идентификатор экземпляра: тип и порядковый номер создания в шестнадцатеричной записи.
  static String _id(BlocBase<Object?> bloc) {
    final id = _ids[bloc] ??= '${bloc.runtimeType}#${(++_counter).toRadixString(16)}';

    return id;
  }

  static Map<String, Object?>? _data({Object? event, Object? state}) {
    final data = <String, Object?>{
      if (event is TailsLoggable) 'event': event.toLogData(),
      if (state is TailsLoggable) 'state': state.toLogData(),
    };

    return data.isEmpty ? null : data;
  }

  /// Имя типа без префикса sealed-класса: `PetDetailsState$Loading` → `Loading`.
  static String _shortName(Object? object) {
    final name = '${object.runtimeType}';
    final separator = name.lastIndexOf(r'$');

    return separator == -1 ? name : name.substring(separator + 1);
  }
}
