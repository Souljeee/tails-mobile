import 'package:tails_mobile/src/core/logging/tails_log_context.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

/// Пишет первую запись запуска: что за сборка, окружение и устройство.
///
/// ```text
/// 12:03:40.101 I APP  App  Приложение запущено version=0.0.1 build=1 env=DEV platform=ios
///   os="iOS 18.1" device=iPhone16,2 session=8f2c41a7
/// ```
///
/// Сюда попадают только сведения о сборке и устройстве, без данных пользователя.
abstract final class AppStartLogger {
  /// Записывает запуск. Все сведения передаёт вызывающий код, чтобы ядро журнала не зависело
  /// от плагинов и функций приложения.
  static void log({
    required String version,
    required String buildNumber,
    required String environment,
    required String platform,
    String? osVersion,
    String? deviceModel,
  }) {
    TailsLogger.info(
      'Приложение запущено',
      category: TailsLogCategory.app,
      source: 'App',
      data: {
        'version': version,
        'build': buildNumber,
        'env': environment,
        'platform': platform,
        if (osVersion != null && osVersion.isNotEmpty) 'os': osVersion,
        if (deviceModel != null && deviceModel.isNotEmpty) 'device': deviceModel,
        if (TailsLogContext.sessionId case final session?) 'session': session,
      },
    );
  }
}
