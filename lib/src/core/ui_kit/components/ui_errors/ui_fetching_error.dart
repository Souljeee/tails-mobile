import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_empty_state/ui_empty_state.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

class UiFetchingError extends StatelessWidget {
  final VoidCallback onRetry;

  const UiFetchingError({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return UiEmptyState(
      illustration: context.uiImages.errorNetwork.image(),
      title: context.l10n.fetchingErrorTitle,
      message: context.l10n.fetchingErrorMessage,
      actionLabel: context.l10n.fetchingErrorRetry,
      onAction: onRetry,
    );
  }
}
