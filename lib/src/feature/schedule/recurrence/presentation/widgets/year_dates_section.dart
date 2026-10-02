import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_hint_banner/ui_hint_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_wheel_panel/ui_wheel_panel.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_section_title.dart';

/// Даты года: выбранные — чипы («5 октября»), новая добавляется барабаном «день + месяц».
class YearDatesSection extends StatefulWidget {
  const YearDatesSection({required this.draft, required this.onChanged, super.key});

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;

  @override
  State<YearDatesSection> createState() => _YearDatesSectionState();
}

class _YearDatesSectionState extends State<YearDatesSection> {
  static const int _monthsInYear = 12;
  static const int _maxDayInMonth = 31;

  bool _adding = false;
  YearDate _pending = const YearDate(1, 1);

  /// Наибольшее число месяца (февраль — 29: правило допускает 29 февраля).
  static int _daysIn(int month) => switch (month) {
    2 => 29,
    4 || 6 || 9 || 11 => 30,
    _ => _maxDayInMonth,
  };

  void _startAdding() {
    final date = widget.draft.eventDate;
    setState(() {
      _pending = YearDate(date.month, date.day);
      _adding = true;
    });
  }

  void _confirm() {
    widget.onChanged(widget.draft.toggleYearDate(_pending));
    setState(() => _adding = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecurrenceSectionTitle(l10n.recurrenceYearDatesTitle),
        Wrap(
          spacing: UiSpacing.x2,
          runSpacing: UiSpacing.x2,
          children: [
            for (final date in draft.yearDates)
              UiChip(
                label: l10n.recurrenceDayMonth(
                  date.day,
                  l10n.recurrenceMonthGenitive('${date.month}'),
                ),
                selected: true,
                onTap: () => widget.onChanged(draft.toggleYearDate(date)),
              ),
            if (!_adding)
              UiChip(label: l10n.recurrenceAddDate, selected: false, onTap: _startAdding),
          ],
        ),
        if (_adding) ...[
          const SizedBox(height: UiSpacing.x3),
          UiWheelPanel(
            columns: [
              UiWheelColumn(
                labels: [for (var d = 1; d <= _daysIn(_pending.month); d++) '$d'],
                selectedIndex: _pending.day - 1,
                onSelected: (index) =>
                    setState(() => _pending = YearDate(_pending.month, index + 1)),
              ),
              UiWheelColumn(
                flex: 2,
                labels: [
                  for (var m = 1; m <= _monthsInYear; m++) l10n.recurrenceMonthGenitive('$m'),
                ],
                selectedIndex: _pending.month - 1,
                onSelected: (index) => setState(() {
                  final month = index + 1;
                  _pending = YearDate(month, _pending.day.clamp(1, _daysIn(month)));
                }),
              ),
            ],
          ),
          const SizedBox(height: UiSpacing.x3),
          UiButton.secondary(label: l10n.recurrenceAddDate, onPressed: _confirm),
        ],
        if (draft.hasFeb29) ...[
          const SizedBox(height: UiSpacing.x3),
          UiHintBanner(text: l10n.recurrenceFeb29Hint),
        ],
      ],
    );
  }
}
