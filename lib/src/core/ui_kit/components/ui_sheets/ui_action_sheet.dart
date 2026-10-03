import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_nav_row/ui_nav_row.dart';

/// Пункт [showUiActionSheet].
class UiActionSheetItem<T> {
  const UiActionSheetItem({
    required this.value,
    required this.icon,
    required this.label,
    this.subtitle,
    this.tone = UiNavRowTone.neutral,
  });

  /// Что вернёт шторка, если выбран этот пункт.
  final T value;
  final IconData icon;
  final String label;
  final String? subtitle;
  final UiNavRowTone tone;
}

/// Шторка со списком действий («Фото профиля», «Помощь и обратная связь»).
///
/// Возвращает [UiActionSheetItem.value] выбранного пункта или `null`, если шторку закрыли.
Future<T?> showUiActionSheet<T>({
  required BuildContext context,
  required String title,
  required String cancelLabel,
  required List<UiActionSheetItem<T>> items,
}) {
  return showUiBottomSheet<T>(
    context: context,
    builder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        UiSheetHeader(title: title, cancelLabel: cancelLabel),
        UiGroupedList(
          dividerIndent: UiNavRow.leadingWidth,
          children: [
            for (final item in items)
              UiNavRow(
                icon: item.icon,
                title: item.label,
                subtitle: item.subtitle,
                tone: item.tone,
                onTap: () => Navigator.of(sheetContext).pop(item.value),
              ),
          ],
        ),
      ],
    ),
  );
}
