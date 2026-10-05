import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tails_mobile/src/core/logging/integrations/logging_http_client.dart';
import 'package:tails_mobile/src/core/logging/integrations/tails_bloc_observer.dart';
import 'package:tails_mobile/src/core/logging/tails_log_context.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/bloc_transformer.dart';

import '../../../helpers/recording_log_sink.dart';

/// Проверяет, что идентификатор BLoC доходит до асинхронного кода обработчика события.
void main() {
  late BlocObserver previousObserver;
  late EventTransformer<dynamic> previousTransformer;

  setUp(() {
    previousObserver = Bloc.observer;
    previousTransformer = Bloc.transformer;
    Bloc.observer = const TailsBlocObserver();
    Bloc.transformer = SequentialBlocTransformer().transform;
  });

  tearDown(() {
    Bloc.observer = previousObserver;
    Bloc.transformer = previousTransformer;
    TailsLogContext.reset();
  });

  test('обработчик видит BLoC, получивший событие, в том числе после await', () async {
    final bloc = _Bloc();
    addTearDown(bloc.close);

    bloc.add(const _Load());
    await bloc.stream.firstWhere((state) => state.length == 2);

    expect(bloc.seen, hasLength(2));
    expect(bloc.seen.first, startsWith('_Bloc#'));
    expect(bloc.seen.first, bloc.seen.last);
  });

  test('одновременные BLoC не путаются', () async {
    final first = _Bloc();
    final second = _Bloc();
    addTearDown(first.close);
    addTearDown(second.close);

    first.add(const _Load());
    second.add(const _Load());
    await Future.wait([
      first.stream.firstWhere((state) => state.length == 2),
      second.stream.firstWhere((state) => state.length == 2),
    ]);

    expect(first.seen.toSet(), hasLength(1));
    expect(second.seen.toSet(), hasLength(1));
    expect(first.seen.first, isNot(second.seen.first));
  });

  test('сетевой запрос из обработчика подписывается BLoC', () async {
    final sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
    addTearDown(TailsLogger.reset);
    final client = LoggingHttpClient(
      MockClient((_) async => http.Response('{}', 200)),
      label: 'api',
    );
    final bloc = _ApiBloc(client);
    addTearDown(bloc.close);

    bloc.add(const _Load());
    await bloc.stream.first;
    await client.get(Uri.parse('https://api.test/outside/'));

    final requests = sink.events
        .where((event) => event.category == TailsLogCategory.network)
        .where((event) => event.message.startsWith('→'))
        .toList();
    expect(requests, hasLength(2));
    expect(requests.first.data['bloc'], matches(RegExp(r'^_ApiBloc#[0-9a-f]+$')));
    expect(requests.last.data.containsKey('bloc'), isFalse);
  });

  test('вне обработчика происхождения нет', () {
    expect(TailsLogContext.origin, isNull);
  });

  test('события подряд обрабатываются по очереди и каждое с идентификатором', () async {
    final bloc = _Bloc();
    addTearDown(bloc.close);

    bloc
      ..add(const _Load())
      ..add(const _Load());
    await bloc.stream.firstWhere((state) => state.length == 4);

    expect(bloc.seen, hasLength(4));
    expect(bloc.seen.toSet(), hasLength(1));
  });
}

final class _Load {
  const _Load();
}

final class _Bloc extends Bloc<_Load, List<int>> {
  _Bloc() : super(const []) {
    on<_Load>((event, emit) async {
      seen.add(TailsLogContext.origin);
      emit([...state, 1]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      seen.add(TailsLogContext.origin);
      emit([...state, 2]);
    });
  }

  final List<String?> seen = [];
}

final class _ApiBloc extends Bloc<_Load, int> {
  _ApiBloc(http.Client client) : super(0) {
    on<_Load>((event, emit) async {
      await client.get(Uri.parse('https://api.test/pets/'));
      emit(1);
    });
  }
}
