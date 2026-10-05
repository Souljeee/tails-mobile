import 'package:tails_mobile/src/core/logging/tails_log_event.dart';

/// Получатель записей журнала: консоль, файл, сервис отчётов об ошибках.
///
/// Реализация сама решает, какие записи ей нужны ([isEnabled]), поэтому у каждого
/// получателя свой порог. [write] не должен бросать исключения и не должен вызывать
/// `TailsLogger`: такие вызовы игнорируются, чтобы не получить бесконечную рекурсию.
abstract interface class TailsLogSink {
  /// Нужны ли получателю записи с таким [level] и [category].
  ///
  /// Вызывается до создания записи, поэтому должен быть быстрым.
  bool isEnabled(TailsLogLevel level, TailsLogCategory category);

  /// Принимает запись.
  void write(TailsLogEvent event);
}
