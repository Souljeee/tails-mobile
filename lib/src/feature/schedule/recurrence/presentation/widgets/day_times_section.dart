import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_row/ui_icon_row.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stepper/ui_stepper.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_limits.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_panel.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_scroll_target.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_section_label.dart';

/// «В течение дня»: сколько раз в день и время каждого раза (только для «День»).
///
/// Для события «весь день» (времени нет) блок скрыт.
class DayTimesSection extends StatelessWidget {
  const DayTimesSection({
    required this.draft,
    required this.onChanged,
    required this.panel,
    required this.onPanel,
    super.key,
  });

  /// Плиток времени в ряду.
  static const int tilesPerRow = 3;

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;
  final RecurrencePanel? panel;
  final ValueChanged<RecurrencePanel?> onPanel;

  @override
  Widget build(BuildContext context) {
    if (!draft.supportsTimes) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final active = switch (panel) {
      RecurrencePanel$Time(:final index) => index,
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RecurrenceSectionLabel(l10n.recurrenceDuringDay),
        UiCard(
          padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4, vertical: UiSpacing.x2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiIconRow(
                icon: Icons.schedule_rounded,
                title: l10n.recurrenceTimesPerDay(draft.timesCount),
                subtitle: l10n.recurrenceTimesSubtitle,
                trailing: UiStepper(
                  value: draft.timesCount,
                  max: RecurrenceLimits.maxTimesPerDay,
                  decrementLabel: l10n.recurrenceDecrease,
                  incrementLabel: l10n.recurrenceIncrease,
                  onChanged: (value) {
                    final next = draft.withTimesCount(value);
                    onChanged(next);
                    if (active != null && active >= next.timesCount) {
                      onPanel(null);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: UiSpacing.x2),
                child: draft.timesCount == 1
                    ? RecurrenceScrollTarget(
                        active: active == 0,
                        child: _TimeTile(
                          label: l10n.recurrenceAsInEvent,
                          time: draft.times.first.format(),
                          active: active == 0,
                          onTap: () => onPanel(active == 0 ? null : const RecurrencePanel.time(0)),
                        ),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final width =
                              (constraints.maxWidth - UiSpacing.x2 * (tilesPerRow - 1)) /
                              tilesPerRow;

                          return Wrap(
                            spacing: UiSpacing.x2,
                            runSpacing: UiSpacing.x2,
                            children: [
                              for (var i = 0; i < draft.times.length; i++)
                                SizedBox(
                                  width: width,
                                  child: RecurrenceScrollTarget(
                                    active: active == i,
                                    child: _TimeTile(
                                      label: l10n.recurrenceTimeN(i + 1),
                                      time: draft.times[i].format(),
                                      active: active == i,
                                      onTap: () =>
                                          onPanel(active == i ? null : RecurrencePanel.time(i)),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        if (draft.timesCount == 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(UiSpacing.x1, UiSpacing.x3, UiSpacing.x1, 0),
            child: Text(
              l10n.recurrenceEventTimeHint,
              style: context.uiFonts.footnote.copyWith(color: palette.ink2),
            ),
          ),
      ],
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({
    required this.label,
    required this.time,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String time;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Semantics(
      button: true,
      selected: active,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: UiRadius.mdAll,
          border: Border.all(color: active ? palette.accent : palette.controlLine),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: UiRadius.mdAll,
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x3, vertical: UiSpacing.x2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: fonts.footnote.copyWith(color: palette.ink2),
                ),
                Text(time, style: fonts.monoDigits.copyWith(color: palette.ink)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
