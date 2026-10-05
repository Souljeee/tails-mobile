import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/logging/tails_log_context.dart';

/// A function that maps an event of type [Event] to a stream of events.
abstract base class BlocTransformer<Event> {
  /// Transforms the given [stream] of events.
  Stream<E> transform<E>(Stream<E> stream, EventMapper<E> mapper);
}

/// Sequentially maps events to a stream of events.
final class SequentialBlocTransformer extends BlocTransformer<Object?> {
  @override
  Stream<Event> transform<Event>(Stream<Event> stream, EventMapper<Event> mapper) =>
      _withOrigin(stream, mapper, TailsLogContext.creatingBloc);

  /// Обработчик события работает в зоне с идентификатором BLoC, чтобы журнал связал
  /// сетевые запросы с BLoC, который их вызвал. [origin] — BLoC, регистрирующий обработчик.
  static Stream<Event> _withOrigin<Event>(
    Stream<Event> stream,
    EventMapper<Event> mapper,
    String? origin,
  ) => stream.asyncExpand(
    origin == null ? mapper : (event) => TailsLogContext.runWithOrigin(origin, () => mapper(event)),
  );
}
