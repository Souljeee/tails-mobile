import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] to re-evaluate `redirect` when a stream emits.
///
/// Typically used to refresh routing on auth-state changes.
final class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<Object?> _subscription;

  GoRouterRefreshStream(Stream<Object?> stream) {
    _subscription = stream.listen(
      (_) => notifyListeners(),
      onError: (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

