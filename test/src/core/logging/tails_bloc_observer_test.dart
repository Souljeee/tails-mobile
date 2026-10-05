import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/integrations/tails_bloc_observer.dart';
import 'package:tails_mobile/src/core/logging/sinks/error_reporter_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_loggable.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/error_reporter/error_reporter.dart';

import '../../../helpers/recording_log_sink.dart';

void main() {
  late BlocObserver previousObserver;

  setUp(() {
    previousObserver = Bloc.observer;
    Bloc.observer = const TailsBlocObserver();
  });

  tearDown(() {
    Bloc.observer = previousObserver;
    TailsLogger.reset();
  });

  test('пишет жизненный цикл, событие и переход, не раскрывая содержимое', () async {
    final sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
    final bloc = _CounterBloc();

    bloc.add(const _Increment(secret: '+79001112233'));
    await pumpEventQueue();
    await bloc.close();

    final messages = sink.events.map((event) => event.message).toList();
    expect(messages, ['создан', '⇢ _Increment', 'int → int ‹_Increment›', 'закрыт']);
    expect(messages.join(), isNot(contains('79001112233')));
    expect(sink.events.every((event) => event.category == TailsLogCategory.bloc), isTrue);
    expect(sink.events.every((event) => event.data.isEmpty), isTrue);
  });

  test('идентификатор постоянен для экземпляра и различает экземпляры одного типа', () async {
    final sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);

    final first = _CounterBloc();
    final second = _CounterBloc();
    first.add(const _Increment(secret: ''));
    await pumpEventQueue();
    await first.close();
    await second.close();

    final idPattern = RegExp(r'^_CounterBloc#[0-9a-f]+$');
    final firstSources = sink.events.map((event) => event.source).toSet();
    expect(firstSources.every((source) => idPattern.hasMatch('$source')), isTrue);
    expect(firstSources, hasLength(2));

    // Все записи первого экземпляра — с одним id: создан, событие, переход, закрыт.
    expect(sink.events.where((event) => event.source == sink.events.first.source), hasLength(4));
  });

  test('Cubit пишет изменения через onChange', () async {
    final sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
    final cubit = _CounterCubit();

    cubit.increment();
    await cubit.close();

    expect(sink.events.map((event) => event.message), ['создан', 'int → int', 'закрыт']);
  });

  test('Bloc не дублирует переход записью onChange', () async {
    final sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
    final bloc = _CounterBloc();

    bloc.add(const _Increment(secret: ''));
    await pumpEventQueue();
    await bloc.close();

    expect(sink.events.where((event) => event.message.contains('→')), hasLength(1));
  });

  test('данные TailsLoggable попадают в запись, остальные события — нет', () async {
    final sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
    final bloc = _LoggableBloc();

    bloc.add(const _Opened(petId: 42));
    await pumpEventQueue();
    await bloc.close();

    final event = sink.events.firstWhere((event) => event.message.startsWith('⇢'));
    expect(event.data, {
      'event': {'petId': 42},
    });
  });

  test('данные TailsLoggable проходят через санитайзер', () async {
    final sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
    final bloc = _LoggableBloc();

    bloc.add(const _Opened(petId: 1, token: 'secret-value'));
    await pumpEventQueue();
    await bloc.close();

    final event = sink.events.firstWhere((event) => event.message.startsWith('⇢'));
    expect('${event.data}', isNot(contains('secret-value')));
  });

  test('ошибка из обработчика пишется как error с исходным исключением', () async {
    final sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
    late _CounterBloc bloc;

    // Bloc пробрасывает ошибку дальше в зону, где он создан, — перехватываем её,
    // как это делает runZonedGuarded в AppRunner.
    await runZonedGuarded(() async {
      bloc = _CounterBloc()..add(const _Fail());
      await pumpEventQueue();
    }, (error, stackTrace) {});
    await bloc.close();

    final errors = sink.events.where((event) => event.level == TailsLogLevel.error);
    expect(errors, hasLength(1));
    expect(errors.single.error, isA<StateError>());
  });

  test('ошибка Bloc, дошедшая до зоны, уходит в сервис отчётов один раз', () async {
    final reporter = _CountingReporter();
    TailsLogger.configure(
      sinks: [ErrorReporterSink(reporter: reporter, config: const TailsLogConfig.debug())],
    );
    late _CounterBloc bloc;

    await runZonedGuarded(
      () async {
        bloc = _CounterBloc()..add(const _Fail());
        await pumpEventQueue();
      },
      (error, stackTrace) {
        // Так же, как GlobalErrorHandler.onZoneError.
        TailsLogger.fatal(
          'Необработанная асинхронная ошибка',
          category: TailsLogCategory.app,
          source: 'Zone',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    await pumpEventQueue();
    await bloc.close();

    expect(reporter.count, 1);
  });
}

sealed class _CounterEvent {
  const _CounterEvent();
}

final class _Increment extends _CounterEvent {
  const _Increment({required this.secret});

  final String secret;
}

final class _Fail extends _CounterEvent {
  const _Fail();
}

final class _CounterBloc extends Bloc<_CounterEvent, int> {
  _CounterBloc() : super(0) {
    on<_Increment>((event, emit) => emit(state + 1));
    on<_Fail>((event, emit) => throw StateError('boom'));
  }
}

final class _CountingReporter implements ErrorReporter {
  int count = 0;

  @override
  bool get isInitialized => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> captureException({required Object throwable, StackTrace? stackTrace}) async {
    count++;
  }

  @override
  void addBreadcrumb({
    required String message,
    required String category,
    BreadcrumbLevel level = BreadcrumbLevel.info,
    Map<String, Object?>? data,
  }) {}
}

final class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

sealed class _LoggableEvent {
  const _LoggableEvent();
}

final class _Opened extends _LoggableEvent implements TailsLoggable {
  const _Opened({required this.petId, this.token});

  final int petId;
  final String? token;

  @override
  Map<String, Object?> toLogData() => {'petId': petId, if (token != null) 'token': token};
}

final class _LoggableBloc extends Bloc<_LoggableEvent, int> {
  _LoggableBloc() : super(0) {
    on<_Opened>((event, emit) => emit(state + 1));
  }
}
