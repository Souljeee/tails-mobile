import 'package:flutter/widgets.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

/// Пишет в журнал смену состояния приложения: свернули, вернулись, закрыли.
///
/// ```text
/// 12:07:02.118 I APP  Lifecycle  resumed → inactive
/// 12:07:02.121 I APP  Lifecycle  inactive → hidden
/// ```
///
/// Нужен, чтобы по журналу понимать, что происходило в фоне: сколько приложение было
/// свёрнуто и не оно ли «зависло» после возвращения. Создаётся после
/// `WidgetsFlutterBinding.ensureInitialized()` и живёт всё время работы приложения.
final class AppLifecycleLogger {
  /// Создаёт наблюдателя и сразу начинает слушать.
  ///
  /// [binding] нужен тестам; по умолчанию используется `WidgetsBinding.instance`.
  ///
  /// [onPaused] вызывается, когда приложение ушло в фон (например, чтобы сбросить журнал
  /// на диск, пока система не завершила процесс).
  AppLifecycleLogger({WidgetsBinding? binding, VoidCallback? onPaused}) : _onPaused = onPaused {
    final effectiveBinding = binding ?? WidgetsBinding.instance;
    _previous = effectiveBinding.lifecycleState;
    _listener = AppLifecycleListener(binding: effectiveBinding, onStateChange: _onStateChange);
  }

  static const String _source = 'Lifecycle';

  final VoidCallback? _onPaused;
  late final AppLifecycleListener _listener;
  AppLifecycleState? _previous;

  /// Прекращает слушать.
  void dispose() => _listener.dispose();

  void _onStateChange(AppLifecycleState state) {
    final previous = _previous;
    _previous = state;

    if (previous == state) return;

    TailsLogger.info(
      '${previous?.name ?? '(start)'} → ${state.name}',
      category: TailsLogCategory.app,
      source: _source,
    );

    if (state == AppLifecycleState.paused) _onPaused?.call();
  }
}
