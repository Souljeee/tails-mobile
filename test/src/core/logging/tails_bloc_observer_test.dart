import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/integrations/tails_bloc_observer.dart';
import 'package:tails_mobile/src/core/logging/sinks/error_reporter_sink.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
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

  test('пишет событие и переход, не раскрывая содержимое', () async {
    final sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
    final bloc = _CounterBloc();

    bloc.add(const _Increment(secret: '+79001112233'));
    await pumpEventQueue();
    await bloc.close();

    final messages = sink.events.map((event) => event.message).toList();
    expect(messages, contains('⇢ _Increment'));
    expect(messages.any((message) => message.contains('_Increment')), isTrue);
    expect(messages.any((message) => message.contains('→')), isTrue);
    expect(messages.join(), isNot(contains('79001112233')));
    expect(sink.events.every((event) => event.category == TailsLogCategory.bloc), isTrue);
    expect(sink.events.first.source, '_CounterBloc');
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
}
