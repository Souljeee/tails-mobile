import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stepper/ui_stepper.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_limits.dart';

/// «Повторять каждые» со счётчиком и единицей: дня, недели, месяца, года.
class RecurrenceIntervalRow extends StatelessWidget {
  const RecurrenceIntervalRow({required this.draft, required this.onChanged, super.key});

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recurrenceIntervalTitle, style: fonts.callout.copyWith(color: palette.ink2)),
        const SizedBox(height: UiSpacing.x2),
        Row(
          children: [
            UiStepper(
              value: draft.interval,
              max: RecurrenceLimits.maxInterval(draft.period),
              decrementLabel: l10n.recurrenceDecrease,
              incrementLabel: l10n.recurrenceIncrease,
              onChanged: (value) => onChanged(draft.withInterval(value)),
            ),
            const SizedBox(width: UiSpacing.x2),
            Flexible(
              child: Text(
                _unit(l10n, draft.period, draft.interval),
                style: fonts.callout.copyWith(color: palette.ink),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _unit(AppLocalizations l10n, RecurrencePeriod period, int n) => switch (period) {
    RecurrencePeriod.day || RecurrencePeriod.unknown => l10n.recurrenceIntervalUnitDays(n),
    RecurrencePeriod.week => l10n.recurrenceIntervalUnitWeeks(n),
    RecurrencePeriod.month => l10n.recurrenceIntervalUnitMonths(n),
    RecurrencePeriod.year => l10n.recurrenceIntervalUnitYears(n),
  };
}
