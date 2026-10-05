import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/logging/integrations/global_error_handler.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

import '../../../helpers/recording_log_sink.dart';

void main() {
  late RecordingLogSink sink;

  setUp(() {
    sink = RecordingLogSink();
    TailsLogger.configure(sinks: [sink]);
  });

  tearDown(TailsLogger.reset);

  group('GlobalErrorHandler', () {
    test('ошибка Flutter пишется как error с исключением и стеком', () {
      final error = StateError('boom');
      final stack = StackTrace.fromString('#0 build (widget.dart:1)');

      GlobalErrorHandler.onFlutterError(
        FlutterErrorDetails(exception: error, stack: stack, library: 'widgets library'),
      );

      final event = sink.events.single;
      expect(event.level, TailsLogLevel.error);
      expect(event.category, TailsLogCategory.app);
      expect(event.source, 'FlutterError');
      expect(event.error, same(error));
      expect(event.stackTrace, same(stack));
      expect(event.data['library'], 'widgets library');
    });

    test('тихая ошибка Flutter пишется как warning', () {
      GlobalErrorHandler.onFlutterError(
        FlutterErrorDetails(exception: StateError('картинка'), silent: true),
      );

      expect(sink.events.single.level, TailsLogLevel.warning);
    });

    test('ошибка платформы пишется как fatal и считается обработанной', () {
      final error = StateError('boom');

      final handled = GlobalErrorHandler.onPlatformError(error, StackTrace.empty);

      expect(handled, isTrue);
      expect(sink.events.single.level, TailsLogLevel.fatal);
      expect(sink.events.single.source, 'PlatformDispatcher');
      expect(sink.events.single.error, same(error));
    });

    test('ошибка зоны пишется как fatal', () {
      final error = StateError('boom');

      GlobalErrorHandler.onZoneError(error, StackTrace.empty);

      expect(sink.events.single.level, TailsLogLevel.fatal);
      expect(sink.events.single.source, 'Zone');
      expect(sink.events.single.error, same(error));
    });

    test('install назначает обработчики Flutter и платформы', () {
      TestWidgetsFlutterBinding.ensureInitialized();
      final previousFlutter = FlutterError.onError;
      final previousPlatform = PlatformDispatcher.instance.onError;
      addTearDown(() {
        FlutterError.onError = previousFlutter;
        PlatformDispatcher.instance.onError = previousPlatform;
      });

      GlobalErrorHandler.install();

      expect(FlutterError.onError, GlobalErrorHandler.onFlutterError);
      expect(PlatformDispatcher.instance.onError, GlobalErrorHandler.onPlatformError);
    });
  });
}
