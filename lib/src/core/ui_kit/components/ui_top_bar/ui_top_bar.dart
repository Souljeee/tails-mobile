import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Верхняя панель вложенных экранов: стрелка назад, заголовок по центру, действия справа.
///
/// Учитывает верхний SafeArea. Размещается в теле экрана, а не в `Scaffold.appBar`.
class UiTopBar extends StatelessWidget {
  const UiTopBar({
    required this.title,
    this.backLabel,
    this.onBack,
    this.actions = const [],
    super.key,
  });

  static const double height = 56;

  final String title;

  /// Подпись кнопки «назад» для скринридера.
  final String? backLabel;

  /// Если `null`, кнопка «назад» не показывается.
  final VoidCallback? onBack;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            const SizedBox(width: UiSpacing.x2),
            SizedBox.square(
              dimension: UiSizes.minTapTarget,
              child: onBack == null
                  ? null
                  : IconButton(
                      onPressed: onBack,
                      tooltip: backLabel,
                      icon: Icon(Icons.chevron_left, size: 28, color: palette.ink),
                    ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.uiFonts.headline.copyWith(color: palette.ink),
              ),
            ),
            if (actions.isEmpty)
              const SizedBox(width: UiSizes.minTapTarget)
            else
              Row(mainAxisSize: MainAxisSize.min, children: actions),
            const SizedBox(width: UiSpacing.x2),
          ],
        ),
      ),
    );
  }
}

/// Крупный заголовок корневых экранов: название, моноширинная подпись и действие справа.
class UiLargeTitleHeader extends StatelessWidget {
  const UiLargeTitleHeader({required this.title, this.subtitle, this.trailing, super.key});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpacing.x5, UiSpacing.x4, UiSpacing.x5, UiSpacing.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, style: fonts.displayM.copyWith(color: palette.ink)),
                ),
                if (subtitle != null)
                  Text(subtitle!, style: fonts.monoMeta.copyWith(color: palette.ink2)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: UiSpacing.x3), trailing!],
        ],
      ),
    );
  }
}
