import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as pkg;
import 'package:tails_mobile/src/core/logging/sinks/console_line_printer.dart';
import 'package:tails_mobile/src/core/logging/tails_log_config.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_formatter.dart';
import 'package:tails_mobile/src/core/logging/tails_log_sink.dart';

/// Выводит журнал в консоль через пакет `logger`.
///
/// Это единственное место приложения, которое знает о `package:logger`: остальной код
/// зависит только от `TailsLogger`, поэтому замена библиотеки затронет только каталог `sinks`.
final class ConsoleLogSink implements TailsLogSink {
  /// Создаёт консольный sink.
  ///
  /// Пороги берутся из [config]. [writeLine] принимает готовые строки; по умолчанию
  /// это `debugPrint`, а в тестах можно подставить свой приёмник.
  ConsoleLogSink({
    required TailsLogConfig config,
    TailsLogFormatter formatter = const TailsLogFormatter(),
    void Function(String line)? writeLine,
  }) : _config = config,
       _logger = pkg.Logger(
         filter: _PassAllFilter(),
         printer: TailsConsolePrinter(formatter),
         output: TailsConsoleOutput(writeLine ?? debugPrint),
       );

  final TailsLogConfig _config;
  final pkg.Logger _logger;

  @override
  bool isEnabled(TailsLogLevel level, TailsLogCategory category) =>
      level.isAtLeast(_config.consoleMinLevelFor(category));

  @override
  void write(TailsLogEvent event) =>
      _logger.log(_toPackageLevel(event.level), event, time: event.time);

  static pkg.Level _toPackageLevel(TailsLogLevel level) => switch (level) {
    TailsLogLevel.trace => pkg.Level.trace,
    TailsLogLevel.debug => pkg.Level.debug,
    TailsLogLevel.info => pkg.Level.info,
    TailsLogLevel.warning => pkg.Level.warning,
    TailsLogLevel.error => pkg.Level.error,
    TailsLogLevel.fatal => pkg.Level.fatal,
  };
}

/// Пропускает всё: пороги уже проверил [ConsoleLogSink.isEnabled].
///
/// Стандартный `DevelopmentFilter` отбрасывает все записи вне debug-режима.
final class _PassAllFilter extends pkg.LogFilter {
  @override
  bool shouldLog(pkg.LogEvent event) => true;
}
