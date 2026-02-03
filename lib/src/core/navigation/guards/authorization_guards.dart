import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/core/navigation/guards/redirect_builder.dart';
import 'package:tails_mobile/src/core/navigation/guards/redirect_result.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/feature/auth/presentation/auth_scope.dart';

final class RedirectIfAuthorizedGuard extends Guard {
  @override
  Pattern get matchPattern => RegExp(r'^/(auth|enter-code)');

  @override
  RedirectResult redirect(BuildContext context, GoRouterState state) {
    final authorizationScope = AuthScope.of(context);

    if (authorizationScope.status == AuthorizationStatus.authorized) {
      return FinishGuards(
        location: const PetsRoute().location,
      );
    }

    return const FinishGuards(
      location: null,
    );
  }
}

final class RedirectIfNotAuthorizedGuard extends Guard {
  @override
  /// Не редиректим, пока пользователь находится в auth-флоу.
  /// Иначе при переходе на `/enter-code` будет "петля" обратно на `/auth`.
  Pattern get matchPattern => RegExp(r'^/(auth|enter-code)');

  @override
  bool get invertRedirect => true;

  @override
  RedirectResult redirect(BuildContext context, GoRouterState state) {
    final authorizationScope = AuthScope.of(context);

    if (authorizationScope.status == AuthorizationStatus.notAuthorized) {
      return FinishGuards(
        location: const AuthRoute().location,
      );
    }

    return const NextGuard();
  }
}
