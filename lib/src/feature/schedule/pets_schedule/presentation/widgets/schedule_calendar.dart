import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/date_time_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/string_extension.dart';

class ScheduleCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime date) onDateTap;

  const ScheduleCalendar({required this.selectedDate, required this.onDateTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.uiColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: MonthCalendar(
          onDateTap: onDateTap,
          style: CalendarStyle(
            resolveDateTextColor: (date) => selectedDate.isSameDate(date)
                ? context.uiColors.white
                : context.uiColors.black80,
            resolveDateBackgroundColor: (date) => selectedDate.isSameDate(date)
                ? context.uiColors.orangePrimary
                : Colors.transparent,
          ),
          headerBuilder:
              (
                month,
                nextMonthButtonHandler,
                previousMonthButtonHandler,
                nextYearButtonHandler,
                previousYearButtonHandler,
              ) {
                final String formattedSelectedMonth = DateFormat.yMMMM()
                    .format(month)
                    .replaceAll(' г.', '')
                    .toFirstLetterUpperCase();

                return Row(
                  children: [
                    GestureDetector(
                      onTap: previousMonthButtonHandler,
                      child: SizedBox.square(
                        dimension: 42,
                        child: Center(
                          child: UiSvgImage(
                            svgPath: context.uiIcons.arrowLeft.keyName,
                            color: context.uiColors.black100,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(formattedSelectedMonth, style: context.uiFonts.text16Semibold),
                      ),
                    ),
                    GestureDetector(
                      onTap: nextMonthButtonHandler,
                      child: SizedBox.square(
                        dimension: 42,
                        child: Center(
                          child: UiSvgImage(
                            svgPath: context.uiIcons.arrowRight.keyName,
                            color: context.uiColors.black100,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
        ),
      ),
    );
  }
}
