import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/navigation/scaffold_with_navbar.dart';
import 'package:tails_mobile/src/feature/auth/presentation/auth_screen.dart';
import 'package:tails_mobile/src/feature/enter_code/presentation/enter_code_screen.dart';

part 'routes.g.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

@TypedShellRoute<GlobalShellRoute>(
  routes: [
    TypedGoRoute<AuthRoute>(
      path: '/auth',
      name: 'auth',
    ),
    TypedGoRoute<EnterCodeRoute>(
      path: '/enter-code',
      name: 'enter-code',
    ),
    TypedStatefulShellRoute<HomeShellRoute>(
      branches: [
        TypedStatefulShellBranch<PetsBranch>(
          routes: [
            TypedGoRoute<PetsRoute>(
              path: '/pets',
              name: 'pets',
            ),
          ],
        ),
        TypedStatefulShellBranch<CalendarBranch>(
          routes: [
            TypedGoRoute<CalendarRoute>(
              path: '/calendar',
              name: 'calendar',
            ),
          ],
        ),
        TypedStatefulShellBranch<ProfileBranch>(
          routes: [
            TypedGoRoute<ProfileRoute>(
              path: '/profile',
              name: 'profile',
            ),
          ],
        ),
      ],
    ),
  ],
)
class GlobalShellRoute extends ShellRouteData {
  const GlobalShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) {
    return navigator;
  }
}

class HomeShellRoute extends StatefulShellRouteData {
  const HomeShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    if ([
      const PetsRoute().location,
      const CalendarRoute().location,
      const ProfileRoute().location,
    ].contains(state.uri.path)) {
      return ScaffoldWithNavBar(navigationShell: navigationShell);
    }

    return navigationShell;
  }
}

/// Branches

class PetsBranch extends StatefulShellBranchData {
  const PetsBranch();
}

class CalendarBranch extends StatefulShellBranchData {
  const CalendarBranch();
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}

/// Routes

class AuthRoute extends GoRouteData with $AuthRoute {
  const AuthRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AuthScreen();
}

class EnterCodeRoute extends GoRouteData with $EnterCodeRoute {
  const EnterCodeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const EnterCodeScreen();
}

class PetsRoute extends GoRouteData with $PetsRoute {
  const PetsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SizedBox();
}

class CalendarRoute extends GoRouteData with $CalendarRoute {
  const CalendarRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SizedBox();
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SizedBox();
}
