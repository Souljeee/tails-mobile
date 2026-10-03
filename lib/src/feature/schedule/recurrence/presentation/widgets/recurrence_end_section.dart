import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_expandable_card/ui_expandable_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stepper/ui_stepper.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_calculator.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_limits.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_panel.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_scroll_target.dart';

/// Раскрывающийся блок «Окончание»: без окончания / до даты / после нескольких повторений.
class RecurrenceEndSection extends StatefulWidget {
  const RecurrenceEndSection({
    required this.draft,
    required this.onChanged,
    required this.panel,
    required this.onPanel,
    super.key,
  });

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;
  final RecurrencePanel? panel;
  final ValueChanged<RecurrencePanel?> onPanel;

  @override
  State<RecurrenceEndSection> createState() => _RecurrenceEndSectionState();
}

class _RecurrenceEndSectionState extends State<RecurrenceEndSection> {
  static final _dateFormat = DateFormat('dd.MM.yyyy');

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final draft = widget.draft;
    final end = draft.end;
    final divider = Divider(height: 1, thickness: 1, color: palette.line);

    return UiExpandableCard(
      leading: UiIconBadge(
        icon: Icons.calendar_today_outlined,
        size: 36,
        iconSize: 18,
        foregroundColor: palette.ink2,
        backgroundColor: palette.sunken,
      ),
      title: l10n.recurrenceEndTitle,
      value: switch (end) {
        RecurrenceEnd$Never() => l10n.recurrenceEndNever,
        RecurrenceEnd$Until(:final date) => l10n.recurrenceEndValueUntil(_dateFormat.format(date)),
        RecurrenceEnd$AfterCount(:final count) => l10n.recurrenceEndValueAfter(count),
      },
      expanded: _expanded,
      onToggle: () {
        if (_expanded && widget.panel is RecurrencePanel$EndDate) {
          widget.onPanel(null);
        }
        setState(() => _expanded = !_expanded);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          divider,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiSelectableRow(
                  label: l10n.recurrenceEndNever,
                  selected: end is RecurrenceEnd$Never,
                  onTap: () {
                    widget.onPanel(null);
                    widget.onChanged(draft.withEnd(const RecurrenceEnd.never()));
                  },
                ),
                divider,
                UiSelectableRow(
                  label: l10n.recurrenceEndOnDate,
                  selected: end is RecurrenceEnd$Until,
                  onTap: end is RecurrenceEnd$Until
                      ? null
                      : () => widget.onChanged(
                          draft.withEnd(RecurrenceEnd.until(_defaultUntil(draft))),
                        ),
                ),
                if (end is RecurrenceEnd$Until)
                  RecurrenceScrollTarget(
                    active: widget.panel is RecurrencePanel$EndDate,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: UiSpacing.x3),
                      child: _DateField(
                        text: _dateFormat.format(end.date),
                        active: widget.panel is RecurrencePanel$EndDate,
                        onTap: () => widget.onPanel(
                          widget.panel is RecurrencePanel$EndDate
                              ? null
                              : const RecurrencePanel.endDate(),
                        ),
                      ),
                    ),
                  ),
                divider,
                UiSelectableRow(
                  label: l10n.recurrenceEndAfterCount,
                  selected: end is RecurrenceEnd$AfterCount,
                  onTap: end is RecurrenceEnd$AfterCount
                      ? null
                      : () {
                          widget.onPanel(null);
                          widget.onChanged(draft.withEndCount(RecurrenceLimits.minEndCount));
                        },
                ),
                if (end is RecurrenceEnd$AfterCount)
                  Padding(
                    padding: const EdgeInsets.only(bottom: UiSpacing.x3),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.recurrenceEndCountLabel,
                            style: context.uiFonts.callout.copyWith(color: palette.ink2),
                          ),
                        ),
                        UiStepper(
                          value: end.count,
                          min: RecurrenceLimits.minEndCount,
                          max: RecurrenceLimits.maxEndCount,
                          decrementLabel: l10n.recurrenceDecrease,
                          incrementLabel: l10n.recurrenceIncrease,
                          onChanged: (value) => widget.onChanged(draft.withEndCount(value)),
                        ),
                      ],
                    ),
                  ),
                if (_errorText(context, draft) case final error?)
                  Padding(
                    padding: const EdgeInsets.only(bottom: UiSpacing.x3),
                    child: Text(
                      error,
                      style: context.uiFonts.footnote.copyWith(color: palette.danger),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// По умолчанию — первое повторение, а при его отсутствии — дата события.
  static DateTime _defaultUntil(RecurrenceDraft draft) =>
      RecurrenceCalculator.firstOccurrence(draft.toModel(), draft.eventDate) ?? draft.eventDate;

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

/// Поле с датой окончания: рамка, иконка календаря, шеврон; открывает барабан даты.
class _DateField extends StatelessWidget {
  const _DateField({required this.text, required this.active, required this.onTap});

  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Semantics(
      button: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: UiRadius.mdAll,
          border: Border.all(color: active ? palette.accent : palette.controlLine),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: UiRadius.mdAll,
          splashFactory: NoSplash.splashFactory,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: UiSizes.buttonL),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x3),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 20, color: palette.ink2),
                  const SizedBox(width: UiSpacing.x3),
                  Expanded(
                    child: Text(text, style: context.uiFonts.body.copyWith(color: palette.ink)),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded, color: palette.ink3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
