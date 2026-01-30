import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/string_extension.dart';

typedef OnDateTapCallback = void Function(DateTime date);
typedef OnMonthChangeCallback = void Function(DateTime date);
typedef DateColorResolver = Color Function(DateTime date);
typedef ShowBadgeResolver = bool Function(DateTime date);

class DateConstraints extends Equatable {
  final DateTime? minDate;
  final DateTime? maxDate;

  const DateConstraints({
    this.minDate,
    this.maxDate,
  });

  @override
  List<Object?> get props => [
        minDate,
        maxDate,
      ];
}

class CalendarStyle extends Equatable {
  final DateColorResolver? resolveDateTextColor;
  final DateColorResolver? resolveDateBackgroundColor;
  final DateColorResolver? resolveDateBorderColor;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final Color? backgroundColor;

  const CalendarStyle({
    this.resolveDateTextColor,
    this.resolveDateBackgroundColor,
    this.resolveDateBorderColor,
    this.iconBackgroundColor,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  List<Object?> get props => [
        resolveDateTextColor,
        resolveDateBackgroundColor,
        resolveDateBorderColor,
        iconBackgroundColor,
        iconColor,
        backgroundColor,
      ];
}

class _CalendarStyleProvider extends InheritedWidget {
  final CalendarStyle calendarStyle;

  const _CalendarStyleProvider({
    required this.calendarStyle,
    required super.child,
  });

  static CalendarStyle of(BuildContext context) {
    final _CalendarStyleProvider? result =
        context.dependOnInheritedWidgetOfExactType<_CalendarStyleProvider>();

    assert(result != null, 'No CalendarStyleProvider found in context');

    return result!.calendarStyle;
  }

  @override
  bool updateShouldNotify(_CalendarStyleProvider oldWidget) {
    return calendarStyle != oldWidget.calendarStyle;
  }
}

class _DateConstraintsProvider extends InheritedWidget {
  final DateConstraints dateConstraints;

  const _DateConstraintsProvider({
    required this.dateConstraints,
    required super.child,
  });

  // ignore: unused_element
  static DateConstraints of(BuildContext context) {
    final _DateConstraintsProvider? result =
        context.dependOnInheritedWidgetOfExactType<_DateConstraintsProvider>();

    assert(result != null, 'No DateConstraintsProvider found in context');

    return result!.dateConstraints;
  }

  @override
  bool updateShouldNotify(_DateConstraintsProvider oldWidget) {
    return dateConstraints != oldWidget.dateConstraints;
  }
}

class MonthCalendar extends StatefulWidget {
  final DateTime? initialMonth;
  final OnDateTapCallback? onDateTap;
  final CalendarStyle? style;
  final DateConstraints? dateConstraints;
  final Widget? badgeWidget;
  final OnMonthChangeCallback? onChangeMonth;

  const MonthCalendar({
    this.initialMonth,
    this.dateConstraints,
    this.onDateTap,
    this.style,
    this.badgeWidget,
    this.onChangeMonth,
    super.key,
  });

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime selectedMonth = widget.initialMonth ?? DateTime.now().monthStart;

  CalendarStyle get _defaultStyle => CalendarStyle(
        resolveDateTextColor: (_) => context.uiColors.black50,
      );

  DateConstraints get _defaultConstraints => const DateConstraints();

  @override
  Widget build(BuildContext context) {
    return _CalendarStyleProvider(
      calendarStyle: widget.style ?? _defaultStyle,
      child: _DateConstraintsProvider(
        dateConstraints: widget.dateConstraints ?? _defaultConstraints,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CalendarHeader(
              month: selectedMonth,
              nextYearButtonHandler: () {
                setState(() {
                  selectedMonth = selectedMonth.addYear(1);

                  widget.onChangeMonth?.call(selectedMonth);
                });
              },
              previousYearButtonHandler: () {
                setState(() {
                  selectedMonth = selectedMonth.subtractYear(1);

                  widget.onChangeMonth?.call(selectedMonth);
                });
              },
              nextMonthButtonHandler: () {
                setState(() {
                  selectedMonth = selectedMonth.addMonth(1);

                  widget.onChangeMonth?.call(selectedMonth);
                });
              },
              previousMonthButtonHandler: () {
                setState(() {
                  selectedMonth = selectedMonth.subtractMonth(1);

                  widget.onChangeMonth?.call(selectedMonth);
                });
              },
            ),
            const SizedBox(height: 12),
            _CalendarBody(
              selectedMonth: selectedMonth,
              onDateTap: widget.onDateTap,
              badgeWidget: widget.badgeWidget,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback nextMonthButtonHandler;
  final VoidCallback previousMonthButtonHandler;
  final VoidCallback nextYearButtonHandler;
  final VoidCallback previousYearButtonHandler;

  const _CalendarHeader({
    required this.month,
    required this.nextMonthButtonHandler,
    required this.previousMonthButtonHandler,
    required this.nextYearButtonHandler,
    required this.previousYearButtonHandler,
  });

  @override
  Widget build(BuildContext context) {
    final String formattedSelectedMonth = DateFormat.yMMMM()
        .format(month)
        .replaceAll(
          ' г.',
          '',
        )
        .toFirstLetterUpperCase();

    return Row(
      children: [
        Text(
          formattedSelectedMonth,
          style: context.uiFonts.text20Semibold,
        ),
        const Spacer(),
        _CalendarHeaderButton(
          iconPath: context.uiIcons.doubleArrowLeft.keyName,
          onTap: previousYearButtonHandler,
        ),
        const SizedBox(width: 8),
        _CalendarHeaderButton(
          iconPath: context.uiIcons.arrowLeft.keyName,
          onTap: previousMonthButtonHandler,
        ),
        const SizedBox(width: 8),
        _CalendarHeaderButton(
          iconPath: context.uiIcons.arrowRight.keyName,
          onTap: nextMonthButtonHandler,
        ),
        const SizedBox(width: 8),
        _CalendarHeaderButton(
          iconPath: context.uiIcons.doubleArrowRight.keyName,
          onTap: nextYearButtonHandler,
        ),
      ],
    );
  }
}

class _CalendarHeaderButton extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;

  const _CalendarHeaderButton({
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.square(
        dimension: 42,
        child: Center(
          child: UiSvgImage(
            svgPath: iconPath,
            color: context.uiColors.orangePrimary,
          ),
        ),
      ),
    );
  }
}

class _CalendarBody extends StatefulWidget {
  final DateTime selectedMonth;
  final OnDateTapCallback? onDateTap;
  final Widget? badgeWidget;

  const _CalendarBody({
    required this.selectedMonth,
    required this.onDateTap,
    this.badgeWidget,
  });

  @override
  State<_CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<_CalendarBody> {
  late final List<String> daysOfWeek = [
    context.l10n.monday,
    context.l10n.tuesday,
    context.l10n.wednesday,
    context.l10n.thursday,
    context.l10n.friday,
    context.l10n.saturday,
    context.l10n.sunday,
  ];

  Color get _backgroundColor =>
      _CalendarStyleProvider.of(context).backgroundColor ?? Colors.transparent;

  @override
  Widget build(BuildContext context) {
    final data = _CalendarMonthData(
      year: widget.selectedMonth.year,
      month: widget.selectedMonth.month,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: daysOfWeek
                  .map(
                    (day) => Text(
                      day,
                      style:
                          context.uiFonts.text14Regular.copyWith(color: context.uiColors.black50),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.weeks
                .map(
                  (week) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: week.map((day) {
                      return Expanded(
                        child: _DateItem(
                          key: ValueKey(day.date),
                          date: day.date,
                          isActiveMonth: day.isActiveMonth,
                          onTap: widget.onDateTap,
                          badgeWidget: widget.badgeWidget,
                        ),
                      );
                    }).toList(),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DateItem extends StatefulWidget {
  final OnDateTapCallback? onTap;
  final DateTime date;
  final bool isActiveMonth;
  final Widget? badgeWidget;

  const _DateItem({
    required this.date,
    required this.onTap,
    required this.isActiveMonth,
    this.badgeWidget,
    super.key,
  });

  @override
  State<_DateItem> createState() => _DateItemState();
}

class _DateItemState extends State<_DateItem> {
  Color get _dateBackgroundColor {
    if (!widget.isActiveMonth) {
      return Colors.transparent;
    }

    return _CalendarStyleProvider.of(context).resolveDateBackgroundColor?.call(widget.date) ??
        Colors.transparent;
  }

  Color get _dateBorderColor {
    if (!widget.isActiveMonth) {
      return Colors.transparent;
    }

    return _CalendarStyleProvider.of(context).resolveDateBorderColor?.call(widget.date) ??
        Colors.transparent;
  }

  Color get _dateTextColor {
    if (!widget.isActiveMonth) {
      return Colors.transparent;
    }

    return _CalendarStyleProvider.of(context).resolveDateTextColor?.call(widget.date) ??
        context.uiColors.black50;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isActiveMonth && widget.onTap != null ? () => widget.onTap!(widget.date) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        height: 42,
        margin: const EdgeInsets.all(8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _dateBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: _dateBorderColor,
            width: 2,
          ),
        ),
        duration: const Duration(milliseconds: 100),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 100),
              style: context.uiFonts.header20Medium.copyWith(color: _dateTextColor),
              child: Center(
                child: Text(
                  widget.date.day.toString(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarMonthData {
  final int year;
  final int month;

  const _CalendarMonthData({
    required this.year,
    required this.month,
  });

  static const _daysInWeekCount = 7;

  int get _daysInMonth => DateUtils.getDaysInMonth(year, month);

  int get _weeksCount => ((_daysInMonth + _firstDayOffset) / _daysInWeekCount).ceil();

  int get _firstDayOffset => DateTime(year, month).weekday - 1;

  List<List<_CalendarDayData>> get weeks {
    final res = <List<_CalendarDayData>>[];
    final firstDayMonth = DateTime(year, month);
    DateTime firstDayOfWeek = firstDayMonth.subtract(Duration(days: _firstDayOffset));

    for (var weekIndex = 0; weekIndex < _weeksCount; weekIndex++) {
      final week = List<_CalendarDayData>.generate(
        _daysInWeekCount,
        (index) {
          final date = firstDayOfWeek.add(Duration(days: index));

          final isActiveMonth = date.year == year && date.month == month;

          return _CalendarDayData(
            date: date,
            isActiveMonth: isActiveMonth,
            isActiveDate: date.isToday,
          );
        },
      );

      res.add(week);

      firstDayOfWeek = firstDayOfWeek.add(const Duration(days: _daysInWeekCount));
    }

    return res;
  }
}

class _CalendarDayData {
  final DateTime date;
  final bool isActiveMonth;
  final bool isActiveDate;

  const _CalendarDayData({
    required this.date,
    required this.isActiveMonth,
    required this.isActiveDate,
  });
}

extension DateTimeExtension on DateTime {
  DateTime get monthStart => DateTime(year, month);

  DateTime addMonth(int count) {
    return DateTime(year, month + count, day);
  }

  DateTime subtractMonth(int count) {
    return DateTime(year, month - count, day);
  }

  DateTime subtractYear(int count) {
    return DateTime(year - count, month, day);
  }

  DateTime addYear(int count) {
    return DateTime(year + count, month, day);
  }

  bool isSameDate(DateTime date) {
    return year == date.year && month == date.month && day == date.day;
  }

  bool get isToday {
    return isSameDate(DateTime.now());
  }

  DateTime roundToSeconds() {
    return DateTime(year, month, day, hour, minute, second);
  }

  bool isInRange({
    required DateTime rangeStart,
    required DateTime rangeFinish,
  }) {
    return isAfter(rangeStart.subtract(const Duration(days: 1))) &&
        isBefore(rangeFinish.add(const Duration(days: 1)));
  }

  DateTime get withoutTime => DateTime(year, month, day);
}
