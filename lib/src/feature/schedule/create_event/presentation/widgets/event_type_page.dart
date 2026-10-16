import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_row/ui_icon_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/event_type_rules.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/utils/event_type_options.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_page.dart';

/// Вторая страница шторки «Новое событие»: выбор типа события.
///
/// Нажатие на тип сразу выбирает его: [onSelected] получает тип, отдельной кнопки «Готово» нет.
/// [onBack] закрывает страницу, ничего не меняя. Страница рассчитана на шторку с `fullBleed`
/// и сама задаёт боковые поля и нижнюю безопасную зону; высота совпадает со страницей «Повторение».
class EventTypePage extends StatelessWidget {
  const EventTypePage({
    required this.selected,
    required this.onSelected,
    required this.onBack,
    super.key,
  });

  static const EdgeInsets _sidePadding = EdgeInsets.symmetric(horizontal: UiSpacing.x5);

  final ScheduleEventTypeEnum? selected;
  final ValueChanged<ScheduleEventTypeEnum> onSelected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final height = MediaQuery.sizeOf(context).height * RecurrencePage.heightFactor;
    final current = selected == null ? null : EventTypeRules.pickerType(selected!);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => onBack(),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _sidePadding,
              child: UiSheetHeader.back(
                title: l10n.eventTypePickerTitle,
                backLabel: l10n.recurrenceBack,
                onCancel: onBack,
              ),
            ),
            const SizedBox(height: UiSpacing.x3),
            Expanded(
              child: SingleChildScrollView(
                padding: _sidePadding,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(bottom: UiSpacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final group in EventTypeGroup.values) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: UiSpacing.x1,
                            top: UiSpacing.x2,
                            bottom: UiSpacing.x2,
                          ),
                          child: UiSectionHeader(title: group.title(l10n)),
                        ),
                        UiGroupedList(
                          dividerIndent: UiInfoRow.leadingWidth,
                          children: [
                            for (final option in eventTypeOptions.where((o) => o.group == group))
                              UiIconRow(
                                icon: option.icon,
                                title: option.titleOf(l10n),
                                subtitle: option.subtitleOf(l10n),
                                trailing: option.type == current
                                    ? Icon(Icons.check_rounded, size: 22, color: palette.accent)
                                    : null,
                                onTap: () => onSelected(option.type),
                              ),
                          ],
                        ),
                        const SizedBox(height: UiSpacing.x3),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
