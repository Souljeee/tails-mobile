import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_row/ui_icon_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_segmented_control/ui_segmented_control.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stepper/ui_stepper.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_limits.dart';

/// Карточка «период и интервал»: День / Неделя / Месяц / Год и «Каждые N …» со счётчиком.
class RecurrencePeriodCard extends StatelessWidget {
  const RecurrencePeriodCard({required this.draft, required this.onChanged, super.key});

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return UiCard(
      padding: const EdgeInsets.fromLTRB(UiSpacing.x3, UiSpacing.x3, UiSpacing.x3, UiSpacing.x2),
      child: Column(
        children: [
          UiSegmentedControl<RecurrencePeriod>(
            options: [
              UiSegmentedOption(value: RecurrencePeriod.day, label: l10n.recurrencePeriodDay),
              UiSegmentedOption(value: RecurrencePeriod.week, label: l10n.recurrencePeriodWeek),
              UiSegmentedOption(value: RecurrencePeriod.month, label: l10n.recurrencePeriodMonth),
              UiSegmentedOption(value: RecurrencePeriod.year, label: l10n.recurrencePeriodYear),
            ],
            selected: draft.period,
            onChanged: (period) => onChanged(draft.withPeriod(period)),
          ),
          UiIconRow(
            icon: Icons.repeat_rounded,
            title: _title(l10n, draft.period, draft.interval),
            subtitle: l10n.recurrenceIntervalSubtitle,
            trailing: UiStepper(
              value: draft.interval,
              max: RecurrenceLimits.maxInterval(draft.period),
              decrementLabel: l10n.recurrenceDecrease,
              incrementLabel: l10n.recurrenceIncrease,
              onChanged: (value) => onChanged(draft.withInterval(value)),
            ),
          ),
        ],
      ),
    );
  }

  static String _title(AppLocalizations l10n, RecurrencePeriod period, int n) => switch (period) {
    RecurrencePeriod.day || RecurrencePeriod.unknown =>
      n == 1 ? l10n.recurrenceIntervalRowDayOne : l10n.recurrenceIntervalRowDay(n),
    RecurrencePeriod.week =>
      n == 1 ? l10n.recurrenceIntervalRowWeekOne : l10n.recurrenceIntervalRowWeek(n),
    RecurrencePeriod.month =>
      n == 1 ? l10n.recurrenceIntervalRowMonthOne : l10n.recurrenceIntervalRowMonth(n),
    RecurrencePeriod.year =>
      n == 1 ? l10n.recurrenceIntervalRowYearOne : l10n.recurrenceIntervalRowYear(n),
  };
}
