import 'package:flutter/foundation.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';

/// Правила журнала, зависящие от режима сборки.
///
/// Все пороги и лимиты меняются в одном месте. По мере появления получателей
/// (Sentry, файл) сюда добавляются их пороги.
@immutable
final class TailsLogConfig {
  /// Создаёт конфигурацию с произвольными порогами.
  const TailsLogConfig({required this.consoleMinLevel, this.consoleCategoryMinLevels = const {}});

  /// Debug: в консоль идёт всё.
  const TailsLogConfig.debug() : this(consoleMinLevel: TailsLogLevel.trace);

  /// Profile: подробности `trace` в консоль не идут.
  const TailsLogConfig.profile() : this(consoleMinLevel: TailsLogLevel.debug);

  /// Release: в консоль идут предупреждения и ошибки, а также сетевые запросы.
  const TailsLogConfig.release()
    : this(
        consoleMinLevel: TailsLogLevel.warning,
        consoleCategoryMinLevels: const {TailsLogCategory.network: TailsLogLevel.info},
      );

  /// Конфигурация для текущего режима сборки.
  factory TailsLogConfig.forBuildMode() {
    if (kReleaseMode) return const TailsLogConfig.release();
    if (kProfileMode) return const TailsLogConfig.profile();

    return const TailsLogConfig.debug();
  }

  /// Минимальный уровень записей для консоли.
  final TailsLogLevel consoleMinLevel;

  /// Минимальный уровень для консоли по категориям; перекрывает [consoleMinLevel].
  final Map<TailsLogCategory, TailsLogLevel> consoleCategoryMinLevels;

  /// Минимальный уровень консоли для [category].
  TailsLogLevel consoleMinLevelFor(TailsLogCategory category) =>
      consoleCategoryMinLevels[category] ?? consoleMinLevel;
}
