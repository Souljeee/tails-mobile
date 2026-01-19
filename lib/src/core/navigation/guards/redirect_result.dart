import 'package:go_router/go_router.dart';
import 'package:tails_mobile/src/core/navigation/guards/redirect_builder.dart';

/// Result of [Guard.redirect] method
sealed class RedirectResult {
  const RedirectResult();
}

final class FinishGuards extends RedirectResult {
  /// If null, [GoRouter]'s redirect do not perform incoming route
  final String? location;

  const FinishGuards({
    required this.location,
  });
}

final class NextGuard extends RedirectResult {
  const NextGuard();
}
