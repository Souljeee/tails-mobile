import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_popup/ui_popup.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class CalendarPopup extends StatefulWidget {
  static Future<DateTime?> show({required BuildContext context}) => showUiPopup(
        context: context,
        child: const CalendarPopup._(),
      );

  const CalendarPopup._();

  @override
  State<CalendarPopup> createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  DateTime? _seletedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Выберите дату рождения',
          style: context.uiFonts.header28Semibold,
        ),
        const SizedBox(height: 16),
        MonthCalendar(
          onDateTap: (date) {
            setState(() {
              _seletedDate = date;
            });
          },
          style: CalendarStyle(
            resolveDateTextColor: (date) => _seletedDate?.isSameDate(date) ?? false
                ? context.uiColors.white
                : context.uiColors.black80,
            resolveDateBackgroundColor: (date) => _seletedDate?.isSameDate(date) ?? false
                ? context.uiColors.orangePrimary
                : Colors.transparent,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: UiButton.main(
            label: 'Выбрать',
            onPressed: () {
              Navigator.pop(context, _seletedDate);
            },
          ),
        ),
      ],
    );
  }
}
