import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_day_toggle/ui_day_toggle.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_hint_banner/ui_hint_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_section_label.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_time_hint.dart';

/// «Числа месяца»: выбранные числа и «Изменить»; сетка 1–31 и «Последний день» — по «Изменить».
class MonthDaysSection extends StatefulWidget {
  const MonthDaysSection({required this.draft, required this.onChanged, super.key});

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;

  @override
  State<MonthDaysSection> createState() => _MonthDaysSectionState();
}

class _MonthDaysSectionState extends State<MonthDaysSection> {
  static const int _columns = 7;
  static const int _lastRowStart = 29;
  static const int _lastDay = 31;

  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecurrenceSectionLabel(l10n.recurrenceMonthDaysLabel),
        UiCard(
          child: _editing
              ? _Grid(
                  draft: draft,
                  onChanged: widget.onChanged,
                  onCollapse: () => setState(() => _editing = false),
                )
              : _Selected(draft: draft, onEdit: () => setState(() => _editing = true)),
        ),
        if (draft.hasMonthTransfer) ...[
          const SizedBox(height: UiSpacing.x3),
          UiHintBanner(
            text: l10n.recurrenceMonthTransferHint(
              draft.monthDays.any((d) => d.value == _lastDay)
                  ? l10n.recurrenceMonthExamplesNovFeb
                  : l10n.recurrenceMonthExamplesFeb,
            ),
          ),
        ],
        RecurrenceTimeHint(draft: draft),
      ],
    );
  }
}

class _Selected extends StatelessWidget {
  const _Selected({required this.draft, required this.onEdit});

  final RecurrenceDraft draft;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: UiSpacing.x2,
            runSpacing: UiSpacing.x2,
            children: [
              for (final day in draft.monthDays)
                if (day.isLast)
                  UiChip(label: l10n.recurrenceLastDay, selected: true)
                else
                  UiDayToggle(label: '${day.value}', selected: true),
            ],
          ),
        ),
        const SizedBox(width: UiSpacing.x2),
        Semantics(
          button: true,
          child: InkWell(
            onTap: onEdit,
            splashFactory: NoSplash.splashFactory,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: UiSizes.minTapTarget),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_outlined, size: 18, color: palette.accent),
                  const SizedBox(width: UiSpacing.x1),
                  Text(
                    l10n.recurrenceEdit,
                    style: context.uiFonts.bodyBold.copyWith(color: palette.accent),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.draft, required this.onChanged, required this.onCollapse});

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    const columns = _MonthDaysSectionState._columns;

    Widget cell(int day, double size) => Expanded(
      child: Center(
        child: UiDayToggle(
          size: size,
          label: '$day',
          selected: draft.monthDays.contains(MonthDay(day)),
          onTap: () => onChanged(draft.toggleMonthDay(MonthDay(day))),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.recurrenceMonthPickHint,
                style: fonts.footnote.copyWith(color: palette.ink2),
              ),
            ),
            InkWell(
              onTap: onCollapse,
              splashFactory: NoSplash.splashFactory,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: UiSizes.minTapTarget),
                child: Align(
                  widthFactor: 1,
                  child: Text(
                    l10n.recurrenceCollapse,
                    style: fonts.bodyBold.copyWith(color: palette.accent),
                  ),
                ),
              ),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final size = math.min(UiSizes.minTapTarget, constraints.maxWidth / columns - 2);
            const lastRowStart = _MonthDaysSectionState._lastRowStart;
            const lastDay = _MonthDaysSectionState._lastDay;

            return Column(
              children: [
                for (var start = 1; start < lastRowStart; start += columns)
                  Padding(
                    padding: const EdgeInsets.only(bottom: UiSpacing.x2),
                    child: Row(
                      children: [for (var d = start; d < start + columns; d++) cell(d, size)],
                    ),
                  ),
                Row(
                  children: [
                    for (var d = lastRowStart; d <= lastDay; d++) cell(d, size),
                    Expanded(
                      flex: columns - (lastDay - lastRowStart + 1),
                      child: Center(
                        child: UiChip(
                          label: l10n.recurrenceLastDay,
                          selected: draft.monthDays.contains(MonthDay.last),
                          onTap: () => onChanged(draft.toggleMonthDay(MonthDay.last)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
