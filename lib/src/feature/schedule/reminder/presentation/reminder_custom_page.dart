import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_segmented_control/ui_segmented_control.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_stepper/ui_stepper.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_text_link/ui_text_link.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_page.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/domain/reminder_rules.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_preview_card.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_texts.dart';

/// Третья страница шторки: «Своё время» — число и единица (флоу R2).
///
/// «Готово» передаёт значение в [onApply]; «Назад» и «Выбрать из готовых вариантов» ([onBack])
/// возвращают к списку без сохранения. Если время уже прошло (у разового события), «Готово»
/// недоступна.
class ReminderCustomPage extends StatefulWidget {
  const ReminderCustomPage({
    required this.current,
    required this.eventAt,
    required this.allDay,
    required this.recurring,
    required this.now,
    required this.onApply,
    required this.onBack,
    super.key,
  });

  /// Выбранное в форме напоминание: если это своё время, экран открывается с ним.
  final EventReminder current;
  final DateTime eventAt;
  final bool allDay;
  final bool recurring;
  final DateTime now;
  final ValueChanged<EventReminder> onApply;
  final VoidCallback onBack;

  @override
  State<ReminderCustomPage> createState() => _ReminderCustomPageState();
}

class _ReminderCustomPageState extends State<ReminderCustomPage> {
  static const EdgeInsets _sidePadding = EdgeInsets.symmetric(horizontal: UiSpacing.x5);

  late CustomReminder _value = _initial();

  CustomReminder _initial() {
    final minutes = widget.current.minutes;
    final saved = ReminderRules.isCustom(widget.current, allDay: widget.allDay) && minutes != null
        ? CustomReminder.tryFromMinutes(minutes)
        : null;
    final units = ReminderUnit.availableFor(allDay: widget.allDay);

    return saved != null && units.contains(saved.unit)
        ? saved
        : CustomReminder.initial(allDay: widget.allDay);
  }

  void _set(CustomReminder value) => setState(() => _value = value);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final texts = ReminderTexts(l10n);
    final height = MediaQuery.sizeOf(context).height * RecurrencePage.heightFactor;
    final notifyAt = widget.eventAt.subtract(Duration(minutes: _value.minutes));
    final isPast = !widget.recurring && ReminderSchedule.isPast(notifyAt, now: widget.now);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => widget.onBack(),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _sidePadding,
              child: UiSheetHeader.back(
                title: l10n.reminderCustomTitle,
                backLabel: l10n.recurrenceBack,
                onCancel: widget.onBack,
              ),
            ),
            const SizedBox(height: UiSpacing.x3),
            Expanded(
              child: SingleChildScrollView(
                padding: _sidePadding,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.only(bottom: UiSpacing.x4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ReminderPreviewCard(
                        eventAt: widget.eventAt,
                        allDay: widget.allDay,
                        notifyAt: notifyAt,
                        isPast: isPast,
                      ),
                      const SizedBox(height: UiSpacing.x3),
                      UiCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.reminderCustomLabel,
                              style: fonts.callout.copyWith(color: palette.ink2),
                            ),
                            const SizedBox(height: UiSpacing.x2),
                            Row(
                              children: [
                                UiStepper(
                                  value: _value.amount,
                                  max: _value.unit.maxAmount,
                                  editable: true,
                                  valueLabel: l10n.reminderCustomLabel,
                                  decrementLabel: l10n.reminderDecrement,
                                  incrementLabel: l10n.reminderIncrement,
                                  onChanged: (amount) => _set(_value.withAmount(amount)),
                                ),
                                const SizedBox(width: UiSpacing.x3),
                                Expanded(
                                  child: Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      texts.customLabel(_value),
                                      textAlign: TextAlign.end,
                                      style: fonts.headline.copyWith(color: palette.ink),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: UiSpacing.x3),
                            UiSegmentedControl<ReminderUnit>(
                              options: [
                                for (final unit in ReminderUnit.availableFor(allDay: widget.allDay))
                                  UiSegmentedOption(value: unit, label: texts.unitName(unit)),
                              ],
                              selected: _value.unit,
                              onChanged: (unit) => _set(_value.withUnit(unit)),
                            ),
                            const SizedBox(height: UiSpacing.x3),
                            Text(
                              texts.limit(_value, allDay: widget.allDay),
                              style: fonts.footnote.copyWith(color: palette.ink3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UiSpacing.x4),
                      UiButton.main(
                        label: l10n.reminderCustomDone,
                        onPressed: isPast ? null : () => widget.onApply(_value.toReminder()),
                      ),
                      const SizedBox(height: UiSpacing.x2),
                      Center(
                        child: UiTextLink(label: l10n.reminderCustomBack, onTap: widget.onBack),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
