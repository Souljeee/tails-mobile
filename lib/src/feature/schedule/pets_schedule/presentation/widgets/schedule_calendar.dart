import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/date_time_extension.dart';

/// Карточка месяца: выбранный день — accent-круг, сегодняшний — accent-обводка,
/// под днями точки цветов питомцев, у которых есть события.
class ScheduleCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final MonthCalendarController controller;
  final void Function(DateTime date) onDateTap;
  final DateMarkersResolver resolveMarkers;

  const ScheduleCalendar({
    required this.selectedDate,
    required this.controller,
    required this.onDateTap,
    required this.resolveMarkers,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
      child: UiCard(
        padding: const EdgeInsets.fromLTRB(UiSpacing.x3, UiSpacing.x3, UiSpacing.x3, UiSpacing.x2),
        child: MonthCalendar(
          controller: controller,
          showHeader: false,
          onDateTap: onDateTap,
          style: CalendarStyle(
            resolveDateTextColor: (date) =>
                selectedDate.isSameDate(date) ? palette.surface : palette.ink,
            resolveDateBackgroundColor: (date) =>
                selectedDate.isSameDate(date) ? palette.accent : Colors.transparent,
            resolveDateBorderColor: (date) =>
                DateTime.now().isSameDate(date) && !selectedDate.isSameDate(date)
                ? palette.accent
                : Colors.transparent,
            resolveDateMarkers: resolveMarkers,
          ),
        ),
      ),
    );
  }
}
