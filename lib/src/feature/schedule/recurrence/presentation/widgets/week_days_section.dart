import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_day_toggle/ui_day_toggle.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_section_title.dart';

/// Дни недели («Пн…Вс») и быстрые наборы: будни, выходные, каждый день.
class WeekDaysSection extends StatelessWidget {
  const WeekDaysSection({required this.draft, required this.onChanged, super.key});

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecurrenceSectionTitle(l10n.recurrenceWeekDaysTitle),
        Wrap(
          spacing: UiSpacing.x1,
          runSpacing: UiSpacing.x1,
          children: [
            for (var day = DateTime.monday; day <= DateTime.sunday; day++)
              UiDayToggle(
                label: l10n.recurrenceWeekdayShort('$day'),
                selected: draft.weekDays.contains(day),
                onTap: () => onChanged(draft.toggleWeekDay(day)),
              ),
          ],
        ),
        const SizedBox(height: UiSpacing.x3),
        Wrap(
          spacing: UiSpacing.x2,
          runSpacing: UiSpacing.x2,
          children: [
            UiChip(
              label: l10n.recurrencePresetWeekdays,
              selected: draft.isWeekdaysPreset,
              onTap: () => onChanged(draft.withWeekdaysPreset()),
            ),
            UiChip(
              label: l10n.recurrencePresetWeekend,
              selected: draft.isWeekendPreset,
              onTap: () => onChanged(draft.withWeekendPreset()),
            ),
            UiChip(
              label: l10n.recurrencePresetAllDays,
              selected: draft.isAllDaysPreset,
              onTap: () => onChanged(draft.withAllDaysPreset()),
            ),
          ],
        ),
      ],
    );
  }
}
