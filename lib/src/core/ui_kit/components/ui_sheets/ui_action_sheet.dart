import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Вариант выбора в шторке действий.
class UiActionSheetItem<T> {
  const UiActionSheetItem({
    required this.value,
    required this.icon,
    required this.label,
    this.subtitle,
    this.tone = UiNavRowTone.neutral,
  });

  final T value;
  final IconData icon;
  final String label;
  final String? subtitle;
  final UiNavRowTone tone;
}

/// Шторка с коротким выбором действия: заголовок, одна или несколько групп вариантов и
/// кнопка «Отмена» внизу.
///
/// Каждая группа в [groups] — отдельная карточка (например, «Сделать фото / Выбрать из
/// галереи» и отдельно «Удалить фото»). [showChevron] рисует шеврон у вариантов, которые
/// ведут дальше. Возвращает значение выбранного варианта или `null`, если шторку закрыли.
Future<T?> showUiActionSheet<T>({
  required BuildContext context,
  required String title,
  required String cancelLabel,
  required List<List<UiActionSheetItem<T>>> groups,
  String? subtitle,
  bool showChevron = false,
}) {
  return showUiBottomSheet<T>(
    context: context,
    builder: (sheetContext) => _ActionSheet<T>(
      title: title,
      subtitle: subtitle,
      cancelLabel: cancelLabel,
      groups: groups,
      showChevron: showChevron,
    ),
  );
}

class _ActionSheet<T> extends StatelessWidget {
  const _ActionSheet({
    required this.title,
    required this.subtitle,
    required this.cancelLabel,
    required this.groups,
    required this.showChevron,
  });

  final String title;
  final String? subtitle;
  final String cancelLabel;
  final List<List<UiActionSheetItem<T>>> groups;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: fonts.displayS.copyWith(color: palette.ink)),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: UiSpacing.x1),
          Text(subtitle!, style: fonts.body.copyWith(color: palette.ink2)),
        ],
        const SizedBox(height: UiSpacing.x4),
        for (final group in groups) ...[
          UiGroupedList(
            dividerIndent: UiNavRow.leadingWidth,
            children: [
              for (final item in group)
                UiNavRow(
                  icon: item.icon,
                  title: item.label,
                  subtitle: item.subtitle,
                  tone: item.tone,
                  trailing: showChevron ? null : const SizedBox.shrink(),
                  onTap: () => Navigator.of(context).pop(item.value),
                ),
            ],
          ),
          const SizedBox(height: UiSpacing.x3),
        ],
        UiButton.secondary(
          label: cancelLabel,
          staticFillColor: palette.surface,
          staticItemColor: palette.ink,
          defaultBorderColor: palette.line,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
