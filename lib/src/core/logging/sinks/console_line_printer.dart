import 'package:logger/logger.dart' as pkg;
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_log_formatter.dart';

/// Однострочный принтер для пакета `logger`: формат записи задаёт [TailsLogFormatter].
///
/// Многострочный `PrettyPrinter` не подходит: по рамкам и отступам трудно читать поток
/// событий. Принимает в качестве сообщения [TailsLogEvent].
final class TailsConsolePrinter extends pkg.LogPrinter {
  /// Создаёт принтер с заданным форматтером.
  TailsConsolePrinter(this._formatter);

  final TailsLogFormatter _formatter;

  @override
  List<String> log(pkg.LogEvent event) {
    final message = event.message;
    if (message is TailsLogEvent) return _formatter.format(message);

    return ['$message'];
  }
}

/// Вывод строк в консоль через переданную функцию.
///
/// Стандартный `ConsoleOutput` использует `print`; здесь вывод задаётся снаружи
/// (по умолчанию `debugPrint`), что упрощает проверку в тестах.
final class TailsConsoleOutput extends pkg.LogOutput {
  /// Создаёт вывод, который передаёт каждую строку в [writeLine].
  TailsConsoleOutput(this.writeLine);

  /// Принимает очередную строку журнала.
  final void Function(String line) writeLine;

  @override
  void output(pkg.OutputEvent event) => event.lines.forEach(writeLine);
}
