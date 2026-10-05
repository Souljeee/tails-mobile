import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sink.dart';

/// Получатель журнала для тестов: запоминает записи.
final class RecordingLogSink implements TailsLogSink {
  /// Создаёт sink; [minLevel] отсекает записи ниже порога.
  RecordingLogSink({this.minLevel = TailsLogLevel.trace});

  /// Минимальный уровень принимаемых записей.
  final TailsLogLevel minLevel;

  /// Принятые записи в порядке поступления.
  final List<TailsLogEvent> events = [];

  @override
  bool isEnabled(TailsLogLevel level, TailsLogCategory category) => level.isAtLeast(minLevel);

  @override
  void write(TailsLogEvent event) => events.add(event);
}
