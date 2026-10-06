import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';

/// Имя текущего экрана для событий, которые не знают своего маршрута
/// (`error_state_shown`, `empty_state_shown`). Обновляется [AnalyticsScreenTracker].
abstract final class AnalyticsContext {
  /// Текущий экран в `snake_case`.
  static String screen = 'unknown';
}

/// Отправляет `screen_view` при смене маршрута `go_router`.
///
/// Берётся имя маршрута (`pet-details` → `pet_details`), без параметров пути:
/// в них бывают идентификаторы и другие данные.
final class AnalyticsScreenTracker {
  /// Создаёт трекер. Работа начинается после [start].
  AnalyticsScreenTracker(this._router);

  final GoRouter _router;
  String? _lastScreen;
  bool _started = false;

  /// Начинает слушать переходы; текущий экран отправляется сразу.
  void start() {
    if (_started) return;
    _started = true;

    _router.routerDelegate.addListener(_onChanged);
    _onChanged();
  }

  /// Прекращает слушать переходы.
  void dispose() {
    if (!_started) return;
    _started = false;

    _router.routerDelegate.removeListener(_onChanged);
  }

  void _onChanged() {
    final configuration = _router.routerDelegate.currentConfiguration;
    if (configuration.isError || configuration.isEmpty) return;

    final name = configuration.last.route.name;
    if (name == null) return;

    final screen = screenName(name);
    if (screen == _lastScreen) return;
    _lastScreen = screen;
    AnalyticsContext.screen = screen;

    TailsAnalytics.log(TailsAnalyticsEvents.screenView(screen));
  }

  /// Приводит имя маршрута к `snake_case`.
  static String screenName(String routeName) => routeName.replaceAll('-', '_');
}

/// Отправляет `sheet_view` при открытии именованных шторок и диалогов.
///
/// Безымянные окна пропускаются: их имя не несёт смысла для продукта. Подключается
/// через `GoRouter(observers: [...])`.
final class AnalyticsSheetObserver extends NavigatorObserver {
  /// Создаёт наблюдателя.
  AnalyticsSheetObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) return;

    final name = route.settings.name;
    if (name == null || name.isEmpty) return;

    TailsAnalytics.log(TailsAnalyticsEvents.sheetView(AnalyticsScreenTracker.screenName(name)));
  }
}
