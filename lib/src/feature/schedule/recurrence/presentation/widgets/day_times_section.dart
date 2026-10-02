import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_hint_banner/ui_hint_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stepper/ui_stepper.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_wheel_panel/ui_wheel_panel.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_limits.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_section_title.dart';

/// «Раз в день»: счётчик и список времён с барабаном (только для «Каждый день»).
///
/// Если у события нет времени («весь день»), вместо настроек — подсказка.
class DayTimesSection extends StatefulWidget {
  const DayTimesSection({required this.draft, required this.onChanged, super.key});

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;

  @override
  State<DayTimesSection> createState() => _DayTimesSectionState();
}

class _DayTimesSectionState extends State<DayTimesSection> {
  static const int _hours = 24;
  static const int _minutes = 60;

  int? _editing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;

    if (!draft.supportsTimes) {
      return UiHintBanner(text: l10n.recurrenceNoTimeHint);
    }

    final editing = _editing != null && _editing! < draft.times.length ? _editing : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecurrenceSectionTitle(l10n.recurrenceTimesTitle),
        UiStepper(
          value: draft.timesCount,
          max: RecurrenceLimits.maxTimesPerDay,
          decrementLabel: l10n.recurrenceDecrease,
          incrementLabel: l10n.recurrenceIncrease,
          onChanged: (value) => widget.onChanged(draft.withTimesCount(value)),
        ),
        if (draft.timesCount > 1) ...[
          const SizedBox(height: UiSpacing.x3),
          for (var i = 0; i < draft.times.length; i++) ...[
            _TimeRow(
              index: i,
              time: draft.times[i],
              expanded: editing == i,
              onTap: () => setState(() => _editing = editing == i ? null : i),
            ),
            if (editing == i) ...[
              const SizedBox(height: UiSpacing.x2),
              UiWheelPanel(
                columns: [
                  UiWheelColumn(
                    labels: [for (var h = 0; h < _hours; h++) h.toString().padLeft(2, '0')],
                    selectedIndex: draft.times[i].hour,
                    onSelected: (hour) => _change(i, LocalTime(hour, draft.times[i].minute)),
                  ),
                  UiWheelColumn(
                    labels: [for (var m = 0; m < _minutes; m++) m.toString().padLeft(2, '0')],
                    selectedIndex: draft.times[i].minute,
                    onSelected: (minute) => _change(i, LocalTime(draft.times[i].hour, minute)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: UiSpacing.x2),
          ],
        ],
      ],
    );
  }

  /// Правка времени сортирует список, поэтому раскрытая строка следует за значением.
  void _change(int index, LocalTime value) {
    final next = widget.draft.withTimeAt(index, value);
    setState(() => _editing = next.times.indexOf(value));
    widget.onChanged(next);
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.index,
    required this.time,
    required this.expanded,
    required this.onTap,
  });

  final int index;
  final LocalTime time;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return UiCard(
      borderRadius: UiRadius.mdAll,
      showBorder: true,
      showShadow: false,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: UiSizes.buttonM),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.recurrenceTimeN(index + 1),
                  style: fonts.callout.copyWith(color: palette.ink2),
                ),
              ),
              Text(
                time.format(),
                style: fonts.bodySemibold.copyWith(color: expanded ? palette.accent : palette.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
