import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_notice_banner/ui_notice_banner.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/domain/reminder_rules.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_texts.dart';

/// Поле «Напоминание» в форме события и строка состояния под ним.
///
/// Подпись над полем рисует форма. Строка пересчитывается при каждой пересборке: форма
/// перестраивает поле, когда меняются дата, время, тип, повторение или значение.
class ReminderField extends StatelessWidget {
  const ReminderField({
    required this.draft,
    required this.eventAt,
    required this.allDay,
    required this.recurring,
    required this.typePicked,
    required this.pushBlocked,
    required this.now,
    required this.onTap,
    required this.onEnablePush,
    super.key,
  });

  final ReminderDraft draft;

  /// Момент события (у «всего дня» — 09:00 дня события).
  final DateTime eventAt;
  final bool allDay;
  final bool recurring;

  /// Пользователь выбрал тип события.
  final bool typePicked;

  /// Уведомления выключены в системе.
  final bool pushBlocked;
  final DateTime now;
  final VoidCallback onTap;
  final VoidCallback onEnablePush;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final texts = ReminderTexts(l10n);
    final reminder = draft.reminder;
    final notifyAt = ReminderSchedule.notifyAt(
      date: eventAt,
      time: allDay ? null : _hhmm(eventAt),
      reminder: reminder,
    );
    final hint = ReminderHints.of(
      reminder: reminder,
      autoPicked: draft.autoPicked,
      typePicked: typePicked,
      recurring: recurring,
      notifyAt: notifyAt,
      now: now,
      pushBlocked: pushBlocked,
    );
    final value = texts.label(reminder, allDay: allDay);
    final status = switch (hint) {
      ReminderHintKind.at => l10n.reminderWhen(texts.when(notifyAt!, event: eventAt, now: now)),
      ReminderHintKind.byType => l10n.reminderWhenByType(
        texts.when(notifyAt!, event: eventAt, now: now),
      ),
      ReminderHintKind.repeat => l10n.reminderWhenRepeat(_hhmm(notifyAt!)),
      ReminderHintKind.none => l10n.reminderOff,
      ReminderHintKind.past => l10n.reminderWarnPast,
      ReminderHintKind.pushOff => l10n.reminderWarnPush,
    };
    final spokenStatus = switch (hint) {
      ReminderHintKind.at || ReminderHintKind.byType => l10n.reminderWhen(
        texts.spokenWhen(notifyAt!, event: eventAt, now: now),
      ),
      _ => status,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          excludeSemantics: true,
          label: l10n.reminderFieldSemantics(lowerFirst(value), spokenStatus),
          onTap: onTap,
          child: UiCard(
            showShadow: false,
            showBorder: true,
            borderRadius: UiRadius.mdAll,
            onTap: onTap,
            padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4, vertical: UiSpacing.x3),
            child: Row(
              children: [
                Icon(Icons.notifications_none_rounded, size: 24, color: palette.ink2),
                const SizedBox(width: UiSpacing.x3),
                Expanded(
                  child: Text(value, style: fonts.body.copyWith(color: palette.ink)),
                ),
                Icon(Icons.chevron_right_rounded, color: palette.ink3),
              ],
            ),
          ),
        ),
        const SizedBox(height: UiSpacing.x2),
        Semantics(
          liveRegion: true,
          child: switch (hint) {
            ReminderHintKind.past => UiNoticeBanner(
              icon: Icons.error_outline_rounded,
              text: status,
            ),
            ReminderHintKind.pushOff => UiNoticeBanner(
              icon: Icons.notifications_off_outlined,
              text: status,
              actionLabel: l10n.reminderWarnPushAction,
              onAction: onEnablePush,
            ),
            _ => ReminderStatusLine(
              icon: hint == ReminderHintKind.none
                  ? Icons.info_outline_rounded
                  : Icons.schedule_rounded,
              text: status,
            ),
          },
        ),
      ],
    );
  }

  static String _hhmm(DateTime value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

/// Спокойная строка состояния: иконка и серый текст.
class ReminderStatusLine extends StatelessWidget {
  const ReminderStatusLine({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 16, color: palette.ink3),
        ),
        const SizedBox(width: UiSpacing.x2),
        Expanded(
          child: Text(text, style: context.uiFonts.footnote.copyWith(color: palette.ink3)),
        ),
      ],
    );
  }
}
