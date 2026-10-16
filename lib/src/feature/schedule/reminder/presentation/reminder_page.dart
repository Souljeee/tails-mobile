import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_notice_banner/ui_notice_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/event_reminder.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_page.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/domain/reminder_rules.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_option_row.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_preview_card.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_texts.dart';

/// Вторая страница шторки: выбор напоминания (флоу R1, R3).
///
/// Тап по варианту сразу выбирает его ([onSelected]), кнопки «Готово» нет. [onBack] закрывает
/// страницу; значение в форме уже обновлено. У повторяющегося события варианты не блокируются:
/// следующие повторения придут.
class ReminderPage extends StatelessWidget {
  const ReminderPage({
    required this.reminder,
    required this.eventAt,
    required this.allDay,
    required this.recurring,
    required this.now,
    required this.onSelected,
    required this.onOpenCustom,
    required this.onBack,
    super.key,
  });

  static const EdgeInsets _sidePadding = EdgeInsets.symmetric(horizontal: UiSpacing.x5);

  final EventReminder reminder;

  /// Момент события (у «всего дня» — 09:00 дня события).
  final DateTime eventAt;
  final bool allDay;
  final bool recurring;
  final DateTime now;
  final ValueChanged<EventReminder> onSelected;
  final VoidCallback onOpenCustom;
  final VoidCallback onBack;

  DateTime _notifyAt(int minutes) => eventAt.subtract(Duration(minutes: minutes));

  bool _isPast(int minutes) => !recurring && ReminderSchedule.isPast(_notifyAt(minutes), now: now);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final texts = ReminderTexts(l10n);
    final height = MediaQuery.sizeOf(context).height * RecurrencePage.heightFactor;
    final presets = ReminderRules.presets(allDay: allDay);
    final selectedMinutes = reminder.minutes;
    final isCustom = ReminderRules.isCustom(reminder, allDay: allDay);
    final showPastBanner = !recurring && eventAt.isAfter(now) && presets.any(_isPast);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => onBack(),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: _sidePadding,
              child: UiSheetHeader.back(
                title: l10n.reminderPageTitle,
                backLabel: l10n.recurrenceBack,
                onCancel: onBack,
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
                      if (showPastBanner) ...[
                        UiNoticeBanner(
                          text: l10n.reminderPastBanner(texts.left(eventAt.difference(now))),
                        ),
                        const SizedBox(height: UiSpacing.x3),
                      ],
                      ReminderPreviewCard(
                        eventAt: eventAt,
                        allDay: allDay,
                        notifyAt: selectedMinutes == null ? null : _notifyAt(selectedMinutes),
                        isPast: selectedMinutes != null && _isPast(selectedMinutes),
                      ),
                      const SizedBox(height: UiSpacing.x3),
                      UiGroupedList(
                        children: [
                          ReminderOptionRow(
                            title: l10n.reminderNone,
                            subtitle: l10n.reminderNoneHint,
                            selected: reminder.isNone,
                            onTap: () => onSelected(const EventReminder.none()),
                          ),
                        ],
                      ),
                      const SizedBox(height: UiSpacing.x3),
                      UiGroupedList(
                        children: [
                          for (final minutes in presets)
                            ReminderOptionRow(
                              title: texts.label(EventReminder.before(minutes), allDay: allDay),
                              subtitle: _isPast(minutes)
                                  ? l10n.reminderOptionPast
                                  : recurring
                                  ? texts.repeatWhen(_notifyAt(minutes), event: eventAt)
                                  : texts.dateTime(_notifyAt(minutes), event: eventAt),
                              selected: selectedMinutes == minutes,
                              semanticsLabel: _isPast(minutes)
                                  ? l10n.reminderOptionPastSemantics(
                                      texts.label(EventReminder.before(minutes), allDay: allDay),
                                    )
                                  : null,
                              onTap: _isPast(minutes)
                                  ? null
                                  : () => onSelected(EventReminder.before(minutes)),
                            ),
                        ],
                      ),
                      const SizedBox(height: UiSpacing.x3),
                      UiGroupedList(
                        children: [
                          ReminderOptionRow(
                            title: isCustom
                                ? texts.label(reminder, allDay: allDay)
                                : l10n.reminderCustom,
                            subtitle: isCustom
                                ? (recurring
                                      ? texts.repeatWhen(
                                          _notifyAt(selectedMinutes!),
                                          event: eventAt,
                                        )
                                      : texts.dateTime(_notifyAt(selectedMinutes!), event: eventAt))
                                : l10n.reminderCustomHint,
                            selected: isCustom,
                            showChevron: true,
                            onTap: onOpenCustom,
                          ),
                        ],
                      ),
                      const SizedBox(height: UiSpacing.x3),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x1),
                        child: Text(
                          recurring ? l10n.reminderFooterRepeat : l10n.reminderFooter,
                          style: fonts.footnote.copyWith(color: palette.ink3),
                        ),
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
