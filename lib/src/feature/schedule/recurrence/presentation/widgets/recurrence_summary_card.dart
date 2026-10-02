import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_calculator.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_summary.dart';

/// Итог правила словами и ближайшие даты; всегда виден над настройками.
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
    final dateFormat = DateFormat('dd.MM');

    return Semantics(
      container: true,
      liveRegion: true,
      child: UiCard(
        color: palette.accentTint,
        showShadow: false,
        borderRadius: UiRadius.mdAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(summary.title, style: fonts.headline.copyWith(color: palette.ink)),
            if (summary.subtitle.isNotEmpty) ...[
              const SizedBox(height: UiSpacing.x1),
              Text(summary.subtitle, style: fonts.callout.copyWith(color: palette.ink2)),
            ],
            if (next.isNotEmpty) ...[
              const SizedBox(height: UiSpacing.x2),
              Text(
                l10n.recurrenceNext(next.map(dateFormat.format).join(', ')),
                style: fonts.footnote.copyWith(color: palette.ink3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
