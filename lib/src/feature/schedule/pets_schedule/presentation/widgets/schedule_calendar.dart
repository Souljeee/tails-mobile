import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/date_time_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/string_extension.dart';

class ScheduleCalendar extends StatefulWidget {
  const ScheduleCalendar({super.key});

  @override
  State<ScheduleCalendar> createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  DateTime selectedDate = DateTime.now();

  void _onDateTap(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

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
          onDateTap: _onDateTap,
          style: CalendarStyle(
            resolveDateTextColor: (date) => selectedDate.isSameDate(date) ? context.uiColors.white : context.uiColors.black80,
            resolveDateBackgroundColor: (date) => selectedDate.isSameDate(date) ? context.uiColors.orangePrimary : Colors.transparent,
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
