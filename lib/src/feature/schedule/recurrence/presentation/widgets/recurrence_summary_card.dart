import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_calculator.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_summary.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/utils/recurrence_date_format.dart';

/// Итог правила словами, частота и время (моно) и три ближайшие даты; закреплён над настройками.
class RecurrenceSummaryCard extends StatelessWidget {
  const RecurrenceSummaryCard({required this.draft, super.key});

  final RecurrenceDraft draft;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final l10n = context.l10n;

    final model = draft.toModel();
    final summary = RecurrenceSummaryBuilder(
      l10n,
    ).build(model, start: draft.eventDate, eventTime: draft.eventTime?.format());
    final next = RecurrenceCalculator.nextOccurrences(model, draft.eventDate);
    final withYear = draft.period == RecurrencePeriod.year;

    return Semantics(
      container: true,
      liveRegion: true,
      child: SizedBox(
        width: double.infinity,
        child: UiCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary.title, style: fonts.displayS.copyWith(color: palette.ink)),
              if (summary.subtitle.isNotEmpty) ...[
                const SizedBox(height: UiSpacing.x1),
                Text(summary.subtitle, style: fonts.monoMeta.copyWith(color: palette.ink2)),
              ],
              if (next.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: UiSpacing.x3),
                  child: Divider(height: 1, thickness: 1, color: palette.line),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: UiSpacing.x1),
                      child: Icon(Icons.calendar_today_outlined, size: 16, color: palette.ink3),
                    ),
                    const SizedBox(width: UiSpacing.x2),
                    Expanded(
                      child: Wrap(
                        spacing: UiSpacing.x2,
                        runSpacing: UiSpacing.x1,
                        children: [
                          for (final date in next)
                            _DatePill(RecurrenceDateFormat.pill(l10n, date, withYear: withYear)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(color: palette.sunken, borderRadius: UiRadius.fullAll),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x3, vertical: UiSpacing.x1),
        child: Text(text, style: context.uiFonts.monoMeta.copyWith(color: palette.ink)),
      ),
    );
  }
}
