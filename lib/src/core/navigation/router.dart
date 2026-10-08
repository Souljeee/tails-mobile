import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/analytics/integrations/analytics_navigation.dart';
import 'package:tails_mobile/src/core/logging/integrations/navigation_logger.dart';
import 'package:tails_mobile/src/core/navigation/go_router_refresh_stream.dart';
import 'package:tails_mobile/src/core/navigation/guards/authorization_guards.dart';
import 'package:tails_mobile/src/core/navigation/guards/redirect_builder.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';

class AppRouter {
  static GoRouter create({
    required GoRouterRefreshStream refreshListenable,
  }) {
    final router = GoRouter(
      initialLocation: const PetsRoute().location,
      routes: $appRoutes,
      refreshListenable: refreshListenable,
      redirect: RedirectBuilder({
        RedirectIfNotAuthorizedGuard(),
        RedirectIfAuthorizedGuard(),
      }),
      observers: [NavigationObserver(), AnalyticsSheetObserver()],
    );

    // Роутер живёт всё время работы приложения, поэтому логгер не освобождается.
    NavigationLogger(router).start();
    AnalyticsScreenTracker(router).start();

    return router;
  }
}
