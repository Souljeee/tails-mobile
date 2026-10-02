import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_day_toggle/ui_day_toggle.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_hint_banner/ui_hint_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_section_title.dart';

/// Числа месяца 1–31, «Последний день» и подсказка про перенос 29–31.
class MonthDaysSection extends StatelessWidget {
  const MonthDaysSection({required this.draft, required this.onChanged, super.key});

  static const int daysInGrid = 31;

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecurrenceSectionTitle(l10n.recurrenceMonthDaysTitle),
        Wrap(
          spacing: UiSpacing.x1,
          runSpacing: UiSpacing.x1,
          children: [
            for (var day = 1; day <= daysInGrid; day++)
              UiDayToggle(
                label: '$day',
                selected: draft.monthDays.contains(MonthDay(day)),
                onTap: () => onChanged(draft.toggleMonthDay(MonthDay(day))),
              ),
          ],
        ),
        const SizedBox(height: UiSpacing.x3),
        UiChip(
          label: l10n.recurrenceLastDay,
          selected: draft.monthDays.contains(MonthDay.last),
          onTap: () => onChanged(draft.toggleMonthDay(MonthDay.last)),
        ),
        if (draft.hasMonthTransfer) ...[
          const SizedBox(height: UiSpacing.x3),
          UiHintBanner(text: l10n.recurrenceMonthTransferHint),
        ],
      ],
    );
  }
}
