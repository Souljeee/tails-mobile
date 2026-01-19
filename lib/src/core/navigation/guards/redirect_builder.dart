import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/navigation/guards/redirect_result.dart';

final class RedirectBuilder {
  final Set<Guard> _guards;

  const RedirectBuilder(this._guards);

  /// Redirects the user to a new location based on the [Guard]s.
  ///
  /// If the location matches the [Guard.matchPattern], the [Guard.redirect]
  /// function will be called.
  String? call(BuildContext context, GoRouterState state) {
    for (final guard in _guards) {
      final matched = guard.matchPattern.matchAsPrefix(state.matchedLocation) != null;

      if (matched != guard.invertRedirect) {
        final RedirectResult result = guard.redirect(context, state);

        switch (result) {
          case FinishGuards():
            return result.location;
          case NextGuard():
            continue;
        }
      }
    }

    return null;
  }
}

/// A guard is a function that is called before the route is built.
abstract base class Guard {
  /// The pattern to match the location.
  Pattern get matchPattern;

  /// If true, the [redirect] function will be called
  /// when the location does not match the [matchPattern].
  ///
  /// If false, the [redirect] function will be called
  /// when the location matches the [matchPattern].
  bool get invertRedirect => false;

  /// The redirect function to be called when
  /// the location matches the [matchPattern].
  RedirectResult redirect(BuildContext context, GoRouterState state);
}
