import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_day_toggle/ui_day_toggle.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_section_label.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_time_hint.dart';

/// «Дни недели»: «Пн…Вс» в один ряд, быстрые наборы «Будни / Выходные / Все дни».
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
        RecurrenceSectionLabel(l10n.recurrenceWeekDaysLabel),
        UiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final size = math.min(
                    UiSizes.minTapTarget,
                    constraints.maxWidth / DateTime.daysPerWeek,
                  );

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var day = DateTime.monday; day <= DateTime.sunday; day++)
                        UiDayToggle(
                          size: size,
                          label: l10n.recurrenceWeekdayShort('$day'),
                          selected: draft.weekDays.contains(day),
                          onTap: () => onChanged(draft.toggleWeekDay(day)),
                        ),
                    ],
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: UiSpacing.x3),
                child: Divider(height: 1, thickness: 1, color: context.uiPalette.line),
              ),
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
          ),
        ),
        RecurrenceTimeHint(draft: draft),
      ],
    );
  }
}
