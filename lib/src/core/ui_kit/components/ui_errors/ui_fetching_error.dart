import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_empty_state/ui_empty_state.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class UiFetchingError extends StatelessWidget {
  final VoidCallback onRetry;

  const UiFetchingError({required this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return UiEmptyState(
      illustration: SvgPicture.asset(context.uiIcons.sadDoc.keyName),
      title: 'Ошибка загрузки',
      message: 'Повторите позднее',
      actionLabel: 'Повторить',
      onAction: onRetry,
    );
  }
}
