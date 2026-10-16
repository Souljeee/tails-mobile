import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/reminder/presentation/reminder_texts.dart';

/// Карточка «Событие / Напомним»: два времени рядом.
///
/// [notifyAt] `null` — «не напоминать» («не будем»); [isPast] — время уже прошло («уже прошло»
/// янтарным).
class ReminderPreviewCard extends StatelessWidget {
  const ReminderPreviewCard({
    required this.eventAt,
    required this.allDay,
    required this.notifyAt,
    required this.isPast,
    super.key,
  });

  final DateTime eventAt;

  /// У события «на весь день» время события не показывается.
  final bool allDay;
  final DateTime? notifyAt;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final texts = ReminderTexts(l10n);
    final notify = notifyAt;
    final remindText = notify == null
        ? l10n.reminderPreviewNever
        : isPast
        ? l10n.reminderPreviewPast
        : texts.dateTime(notify, event: eventAt);
    final remindColor = notify == null
        ? palette.ink3
        : isPast
        ? palette.amber
        : palette.accent;
    final eventText = allDay ? texts.date(eventAt) : texts.dateTime(eventAt, event: DateTime(0));

    return UiCard(
      child: Column(
        children: [
          _PreviewRow(
            icon: Icons.calendar_today_outlined,
            label: l10n.reminderPreviewEvent,
            value: eventText,
            valueColor: palette.ink,
          ),
          const SizedBox(height: UiSpacing.x3),
          _PreviewRow(
            icon: Icons.notifications_none_rounded,
            label: l10n.reminderPreviewRemind,
            value: remindText,
            valueColor: remindColor,
          ),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Row(
      children: [
        Icon(icon, size: 20, color: palette.ink2),
        const SizedBox(width: UiSpacing.x3),
        Text(label, style: fonts.body.copyWith(color: palette.ink2)),
        const SizedBox(width: UiSpacing.x3),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: fonts.bodyBold.copyWith(color: valueColor),
          ),
        ),
      ],
    );
  }
}
