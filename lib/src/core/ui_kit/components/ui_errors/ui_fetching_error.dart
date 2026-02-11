import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class UiFetchingError extends StatelessWidget {
  final VoidCallback onRetry;

  const UiFetchingError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 120),
          SvgPicture.asset(
            context.uiIcons.sadDoc.keyName,
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки',
            style: context.uiFonts.header24Semibold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Повторите позднее',
            style: context.uiFonts.text16Medium.copyWith(color: context.uiColors.brown),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          UiButton.main(
            label: 'Повторить',
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}