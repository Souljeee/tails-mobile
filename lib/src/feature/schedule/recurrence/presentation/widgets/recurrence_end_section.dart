import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_expandable_card/ui_expandable_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stepper/ui_stepper.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_wheel_panel/ui_wheel_panel.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_calculator.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_limits.dart';

/// Раскрывающийся блок «Окончание»: никогда / в дату / после N повторений.
class RecurrenceEndSection extends StatefulWidget {
  const RecurrenceEndSection({required this.draft, required this.onChanged, super.key});

  /// Сколько лет вперёд можно выбрать в барабане даты окончания.
  static const int yearsAhead = 30;

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;

  @override
  State<RecurrenceEndSection> createState() => _RecurrenceEndSectionState();
}

class _RecurrenceEndSectionState extends State<RecurrenceEndSection> {
  static final _dateFormat = DateFormat('dd.MM.yyyy');

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;
    final end = draft.end;

    return UiExpandableCard(
      title: l10n.recurrenceEndTitle,
      value: switch (end) {
        RecurrenceEnd$Never() => l10n.recurrenceEndNever,
        RecurrenceEnd$Until(:final date) => l10n.recurrenceEndUntil(_dateFormat.format(date)),
        RecurrenceEnd$AfterCount(:final count) => l10n.recurrenceEndAfter(count),
      },
      expanded: _expanded,
      onToggle: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: UiSpacing.x2,
            runSpacing: UiSpacing.x2,
            children: [
              UiChip(
                label: l10n.recurrenceEndNever,
                selected: end is RecurrenceEnd$Never,
                onTap: () => widget.onChanged(draft.withEnd(const RecurrenceEnd.never())),
              ),
              UiChip(
                label: l10n.recurrenceEndOnDate,
                selected: end is RecurrenceEnd$Until,
                onTap: end is RecurrenceEnd$Until
                    ? null
                    : () => widget.onChanged(
                        draft.withEnd(RecurrenceEnd.until(_defaultUntil(draft))),
                      ),
              ),
              UiChip(
                label: l10n.recurrenceEndAfterCount,
                selected: end is RecurrenceEnd$AfterCount,
                onTap: end is RecurrenceEnd$AfterCount
                    ? null
                    : () => widget.onChanged(draft.withEndCount(RecurrenceLimits.minEndCount)),
              ),
            ],
          ),
          if (end is RecurrenceEnd$Until) ...[
            const SizedBox(height: UiSpacing.x3),
            _UntilWheel(
              date: end.date,
              firstYear: draft.eventDate.year,
              onChanged: (date) => widget.onChanged(draft.withEnd(RecurrenceEnd.until(date))),
            ),
          ],
          if (end is RecurrenceEnd$AfterCount) ...[
            const SizedBox(height: UiSpacing.x3),
            Text(
              l10n.recurrenceEndCountTitle,
              style: context.uiFonts.callout.copyWith(color: context.uiPalette.ink2),
            ),
            const SizedBox(height: UiSpacing.x2),
            UiStepper(
              value: end.count,
              min: RecurrenceLimits.minEndCount,
              max: RecurrenceLimits.maxEndCount,
              decrementLabel: l10n.recurrenceDecrease,
              incrementLabel: l10n.recurrenceIncrease,
              onChanged: (value) => widget.onChanged(draft.withEndCount(value)),
            ),
            if (_lastDate(draft) case final last?) ...[
              const SizedBox(height: UiSpacing.x2),
              Text(
                l10n.recurrenceEndLast(_dateFormat.format(last)),
                style: context.uiFonts.footnote.copyWith(color: context.uiPalette.ink3),
              ),
            ],
          ],
          if (_errorText(context, draft) case final error?) ...[
            const SizedBox(height: UiSpacing.x2),
            Text(error, style: context.uiFonts.footnote.copyWith(color: context.uiPalette.danger)),
          ],
        ],
      ),
    );
  }

  static DateTime? _lastDate(RecurrenceDraft draft) =>
      RecurrenceCalculator.until(draft.toModel(), draft.eventDate);

  /// По умолчанию — первое повторение, а при его отсутствии — дата события.
  static DateTime _defaultUntil(RecurrenceDraft draft) {
    final first = RecurrenceCalculator.firstOccurrence(draft.toModel(), draft.eventDate);

    return first ?? draft.eventDate;
  }

  static String? _errorText(BuildContext context, RecurrenceDraft draft) {
    final l10n = context.l10n;

    return switch (draft.endError) {
      RecurrenceEndError$BeforeStart() => l10n.recurrenceEndErrorBeforeStart,
      RecurrenceEndError$BeforeFirst(:final first) => l10n.recurrenceEndErrorBeforeFirst(
        _dateFormat.format(first),
      ),
      null => null,
    };
  }
}

class _UntilWheel extends StatelessWidget {
  const _UntilWheel({required this.date, required this.firstYear, required this.onChanged});

  final DateTime date;
  final int firstYear;
  final ValueChanged<DateTime> onChanged;

  static const int _monthsInYear = 12;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lastYear = firstYear + RecurrenceEndSection.yearsAhead;
    final year = date.year.clamp(firstYear, lastYear);
    final daysInMonth = DateUtils.getDaysInMonth(year, date.month);

    DateTime build(int y, int m, int d) =>
        DateTime(y, m, d.clamp(1, DateUtils.getDaysInMonth(y, m)));

    return UiWheelPanel(
      columns: [
        UiWheelColumn(
          labels: [for (var d = 1; d <= daysInMonth; d++) '$d'],
          selectedIndex: date.day.clamp(1, daysInMonth) - 1,
          onSelected: (index) => onChanged(build(year, date.month, index + 1)),
        ),
        UiWheelColumn(
          flex: 2,
          labels: [for (var m = 1; m <= _monthsInYear; m++) l10n.recurrenceMonthGenitive('$m')],
          selectedIndex: date.month - 1,
          onSelected: (index) => onChanged(build(year, index + 1, date.day)),
        ),
        UiWheelColumn(
          flex: 2,
          labels: [for (var y = firstYear; y <= lastYear; y++) '$y'],
          selectedIndex: year - firstYear,
          onSelected: (index) => onChanged(build(firstYear + index, date.month, date.day)),
        ),
      ],
    );
  }
}
