import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/navigation/go_router_refresh_stream.dart';
import 'package:tails_mobile/src/core/navigation/guards/authorization_guards.dart';
import 'package:tails_mobile/src/core/navigation/guards/redirect_builder.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';

class AppRouter {
  static RouterConfig<Object> create({
    required GoRouterRefreshStream refreshListenable,
  }) =>
      GoRouter(
        initialLocation: const PetsRoute().location,
        routes: $appRoutes,
        refreshListenable: refreshListenable,
        redirect: RedirectBuilder({
          RedirectIfNotAuthorizedGuard(),
          RedirectIfAuthorizedGuard(),
        }),
      );
}
