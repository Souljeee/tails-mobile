import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/integrations/app_lifecycle_logger.dart';
import 'package:tails_mobile/src/core/logging/integrations/app_start_logger.dart';
import 'package:tails_mobile/src/core/logging/tails_log_context.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

import '../../../helpers/recording_log_sink.dart';

void main() {
  late RecordingLogSink sink;

  setUp(() {
    sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
  });

  tearDown(() {
    TailsLogger.reset();
    TailsLogContext.reset();
  });

  group('TailsLogContext.startSession', () {
    test('создаёт короткий идентификатор из восьми шестнадцатеричных символов', () {
      final id = TailsLogContext.startSession(random: Random(1));

      expect(id, matches(RegExp(r'^[0-9a-f]{8}$')));
      expect(TailsLogContext.sessionId, id);
    });

    test('каждый запуск получает новый идентификатор', () {
      final first = TailsLogContext.startSession();
      final second = TailsLogContext.startSession();

      expect(first, isNot(second));
    });

    test('reset очищает идентификатор и экран', () {
      TailsLogContext.startSession();
      TailsLogContext.screen = 'pets';

      TailsLogContext.reset();

      expect(TailsLogContext.sessionId, isNull);
      expect(TailsLogContext.screen, isNull);
    });
  });

  group('AppStartLogger', () {
    test('пишет сведения о сборке и устройстве вместе с идентификатором запуска', () {
      final session = TailsLogContext.startSession();

      AppStartLogger.log(
        version: '0.0.1',
        buildNumber: '7',
        environment: 'DEV',
        platform: 'ios',
        osVersion: 'iOS 18.1',
        deviceModel: 'iPhone16,2',
      );

      final event = sink.events.single;
      expect(event.level, TailsLogLevel.info);
      expect(event.category, TailsLogCategory.app);
      expect(event.message, 'Приложение запущено');
      expect(event.data, {
        'version': '0.0.1',
        'build': '7',
        'env': 'DEV',
        'platform': 'ios',
        'os': 'iOS 18.1',
        'device': 'iPhone16,2',
        'session': session,
      });
    });

    test('пропускает пустые сведения', () {
      AppStartLogger.log(
        version: '1.0.0',
        buildNumber: '1',
        environment: 'PROD',
        platform: 'linux',
        deviceModel: '',
      );

      expect(sink.events.single.data.keys, ['version', 'build', 'env', 'platform']);
    });
  });

  group('AppLifecycleLogger', () {
    testWidgets('пишет смену состояния приложения', (tester) async {
      final logger = AppLifecycleLogger(binding: tester.binding);
      addTearDown(logger.dispose);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      final messages = sink.events.map((event) => event.message).toList();
      expect(messages.first, endsWith('→ inactive'));
      expect(messages, contains('hidden → paused'));
      expect(messages.last, endsWith('→ resumed'));
      expect(sink.events.every((event) => event.category == TailsLogCategory.app), isTrue);
      expect(sink.events.every((event) => event.source == 'Lifecycle'), isTrue);
    });

    testWidgets('повторное то же состояние не пишется', (tester) async {
      final logger = AppLifecycleLogger(binding: tester.binding);
      addTearDown(logger.dispose);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      final count = sink.events.length;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

      expect(sink.events, hasLength(count));
    });

    testWidgets('после dispose ничего не пишет', (tester) async {
      final logger = AppLifecycleLogger(binding: tester.binding)..dispose();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);

      expect(sink.events, isEmpty);
      expect(logger, isNotNull);
    });

    testWidgets('onPaused вызывается при уходе в фон', (tester) async {
      var calls = 0;
      final logger = AppLifecycleLogger(binding: tester.binding, onPaused: () => calls++);
      addTearDown(logger.dispose);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      expect(calls, 0);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      expect(calls, 1);
    });
  });
}
