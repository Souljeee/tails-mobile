import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_hint_banner/ui_hint_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_row/ui_icon_row.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_panel.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_scroll_target.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_section_label.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_time_hint.dart';

/// «Даты в году»: список дат (нажатие — барабан «день + месяц») и «Добавить дату».
class YearDatesSection extends StatelessWidget {
  const YearDatesSection({
    required this.draft,
    required this.panel,
    required this.onPanel,
    super.key,
  });

  final RecurrenceDraft draft;
  final RecurrencePanel? panel;
  final ValueChanged<RecurrencePanel?> onPanel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final divider = Divider(height: 1, thickness: 1, color: palette.line);
    final activeDate = switch (panel) {
      RecurrencePanel$YearDate(:final date) => date,
      _ => null,
    };
    final isAdding = panel is RecurrencePanel$YearDate && activeDate == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecurrenceSectionLabel(l10n.recurrenceYearDatesLabel),
        UiCard(
          padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4),
          child: Column(
            children: [
              for (final date in draft.yearDates) ...[
                RecurrenceScrollTarget(
                  active: date == activeDate,
                  child: UiIconRow(
                    icon: Icons.calendar_today_outlined,
                    title: l10n.recurrenceDayMonth(
                      date.day,
                      l10n.recurrenceMonthGenitive('${date.month}'),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: palette.ink3),
                    onTap: () => onPanel(RecurrencePanel.yearDate(date)),
                  ),
                ),
                divider,
              ],
              RecurrenceScrollTarget(
                active: isAdding,
                child: UiIconRow(
                  icon: Icons.add_rounded,
                  title: l10n.recurrenceAddDateRow,
                  accent: true,
                  onTap: () => onPanel(const RecurrencePanel.yearDate(null)),
                ),
              ),
            ],
          ),
        ),
        if (draft.hasFeb29) ...[
          const SizedBox(height: UiSpacing.x3),
          UiHintBanner(text: l10n.recurrenceFeb29Hint),
        ],
        RecurrenceTimeHint(draft: draft),
      ],
    );
  }
}
