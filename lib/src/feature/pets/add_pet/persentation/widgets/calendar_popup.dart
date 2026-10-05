import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/date_time_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

/// Sheet выбора даты рождения. Возвращает выбранную дату или `null`.
class CalendarPopup extends StatefulWidget {
  final DateTime? initialDate;

  static Future<DateTime?> show({required BuildContext context, DateTime? initialDate}) =>
      showUiBottomSheet<DateTime>(
        context: context,
        name: 'calendar',
        builder: (_) => CalendarPopup._(initialDate: initialDate),
      );

  const CalendarPopup._({this.initialDate});

  @override
  State<CalendarPopup> createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  late DateTime? _seletedDate = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiSheetHeader(title: l10n.pickBirthDateTitle, cancelLabel: l10n.cancel),
        const SizedBox(height: UiSpacing.x2),
        MonthCalendar(
          initialMonth: widget.initialDate?.monthStart,
          onDateTap: (date) {
            setState(() {
              _seletedDate = date;
            });
          },
          style: CalendarStyle(
            resolveDateTextColor: (date) =>
                _seletedDate?.isSameDate(date) ?? false ? palette.surface : palette.ink,
            resolveDateBackgroundColor: (date) =>
                _seletedDate?.isSameDate(date) ?? false ? palette.accent : Colors.transparent,
          ),
        ),
        const SizedBox(height: UiSpacing.x4),
        UiButton.main(
          label: l10n.selectAction,
          onPressed: _seletedDate == null ? null : () => Navigator.pop(context, _seletedDate),
        ),
      ],
    );
  }
}
