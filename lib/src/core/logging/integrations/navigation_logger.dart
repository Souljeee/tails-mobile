import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/logging/tails_log_context.dart';
import 'package:tails_mobile/src/core/logging/tails_log_event.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';

/// Пишет в журнал переходы между экранами `go_router`.
///
/// Слушает `routerDelegate`, поэтому видит всё, что меняет текущий маршрут: `go`, `push`,
/// `pop`, результаты redirect'ов и переключение веток нижней навигации. Записывается итог
/// перехода, а не промежуточные redirect'ы.
///
/// ```text
/// 12:03:42.730 I NAV  Router  pets → pet-details path=/pets/:id params={id: 123}
/// ```
///
/// В запись попадают имя маршрута, шаблон пути и параметры, но не готовый адрес: в нём
/// бывают номер телефона и прочие данные. Параметры проходят через санитайзер (телефон
/// маскируется), а `$extra` описывается только типом.
///
/// Имя текущего экрана сохраняется в `TailsLogContext.screen`.
final class NavigationLogger {
  /// Создаёт наблюдателя за `router`. Работа начинается после [start].
  NavigationLogger(this._router);

  static const String _source = 'Router';

  final GoRouter _router;

  String? _lastKey;
  String _currentName = '(start)';
  bool _started = false;

  /// Начинает слушать переходы; текущий маршрут, если он уже есть, записывается сразу.
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

    // У неизвестного адреса нет совпадений, поэтому ошибку проверяем раньше пустоты.
    if (configuration.isError) {
      _logUnknownRoute(configuration.uri, configuration.error);

      return;
    }

    if (configuration.isEmpty) return;

    final route = configuration.last.route;
    final name = route.name ?? configuration.fullPath;
    final key = '$name|${configuration.uri}';

    if (key == _lastKey) return;
    _lastKey = key;

    final params = configuration.pathParameters;
    final query = configuration.uri.queryParameters;
    final extra = configuration.extra;

    TailsLogger.info(
      '$_currentName → $name',
      category: TailsLogCategory.navigation,
      source: _source,
      data: {
        'path': configuration.fullPath,
        if (params.isNotEmpty) 'params': params,
        if (query.isNotEmpty) 'query': query,
        if (extra != null) 'extra': '${extra.runtimeType}',
      },
    );

    _currentName = name;
    TailsLogContext.screen = name;
  }

  void _logUnknownRoute(Uri uri, Object? error) {
    final key = 'error|$uri';
    if (key == _lastKey) return;
    _lastKey = key;

    TailsLogger.warning(
      'Маршрут не найден',
      category: TailsLogCategory.navigation,
      source: _source,
      data: {'path': uri.path},
      error: error,
    );
  }
}

/// Пишет в журнал открытие и закрытие модальных окон: шторок и диалогов.
///
/// Страницы маршрутов (`PageRoute`) пропускаются: их переходы пишет [NavigationLogger].
/// Имя окна берётся из `RouteSettings.name` (для шторок его задаёт `showUiBottomSheet`), а
/// если имени нет, из типа маршрута.
///
/// Подключается к навигатору через `GoRouter(observers: [NavigationObserver()])`.
final class NavigationObserver extends NavigatorObserver {
  /// Создаёт наблюдателя.
  NavigationObserver();

  static const String _source = 'Navigator';

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _log('открыто', route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _log('закрыто', route);

  void _log(String action, Route<dynamic> route) {
    if (route is PageRoute) return;

    TailsLogger.info(
      '$action ${_name(route)}',
      category: TailsLogCategory.navigation,
      source: _source,
      data: {if (TailsLogContext.screen case final screen?) 'screen': screen},
    );
  }

  static String _name(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) return name;

    // `ModalBottomSheetRoute<bool>` → `ModalBottomSheetRoute`.
    return '${route.runtimeType}'.split('<').first;
  }
}
