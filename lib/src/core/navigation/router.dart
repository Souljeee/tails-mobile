import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';

class AppRouter {
  static final RouterConfig<Object> config = GoRouter(
    initialLocation: const PetsRoute().location,
    routes: $appRoutes,
  );
}
