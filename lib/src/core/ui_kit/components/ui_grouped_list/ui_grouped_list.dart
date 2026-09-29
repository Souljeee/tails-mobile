import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Белая карточка со строками, разделёнными тонкими линиями.
class UiGroupedList extends StatelessWidget {
  const UiGroupedList({required this.children, this.dividerIndent = 0, super.key});

  final List<Widget> children;

  /// Отступ разделителя слева, например чтобы линия начиналась от текста.
  final double dividerIndent;

  @override
  Widget build(BuildContext context) {
    final lineColor = context.uiPalette.line;

    return UiCard(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: lineColor, indent: dividerIndent),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Строка «иконка — название — значение» для карточки с данными питомца.
class UiInfoRow extends StatelessWidget {
  const UiInfoRow({required this.icon, required this.label, required this.value, super.key});

  final IconData icon;
  final String label;
  final String value;

  /// Ширина иконки и отступа, для `UiGroupedList.dividerIndent`.
  static const double leadingWidth = 36 + UiSpacing.x3;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: UiSizes.buttonL),
      child: Row(
        children: [
          UiIconBadge(icon: icon, size: 36, iconSize: 18, foregroundColor: palette.ink2),
          const SizedBox(width: UiSpacing.x3),
          Expanded(
            child: Text(label, style: fonts.body.copyWith(color: palette.ink2)),
          ),
          const SizedBox(width: UiSpacing.x3),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: fonts.bodyBold.copyWith(color: palette.ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Строка списка выбора; выбранная выделена жирным шрифтом и галочкой.
class UiSelectableRow extends StatelessWidget {
  const UiSelectableRow({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: UiSizes.buttonL),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: (selected ? fonts.bodyBold : fonts.body).copyWith(color: palette.ink),
                ),
              ),
              if (selected) Icon(Icons.check, size: 22, color: palette.accent),
            ],
          ),
        ),
      ),
    );
  }
}
