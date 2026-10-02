import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/date_time_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/string_extension.dart';

typedef OnDateTapCallback = void Function(DateTime date);
typedef OnMonthChangeCallback = void Function(DateTime date);
typedef DateColorResolver = Color Function(DateTime date);
typedef ShowBadgeResolver = bool Function(DateTime date);

/// Возвращает цвета маркеров событий под числом (обычно цвета питомцев).
typedef DateMarkersResolver = List<Color> Function(DateTime date);
typedef CalendarHeaderBuilder =
    Widget Function(
      DateTime month,
      VoidCallback nextMonthButtonHandler,
      VoidCallback previousMonthButtonHandler,
      VoidCallback nextYearButtonHandler,
      VoidCallback previousYearButtonHandler,
    );

class DateConstraints extends Equatable {
  final DateTime? minDate;
  final DateTime? maxDate;

  const DateConstraints({this.minDate, this.maxDate});

  @override
  List<Object?> get props => [minDate, maxDate];
}

class CalendarStyle extends Equatable {
  final DateColorResolver? resolveDateTextColor;
  final DateColorResolver? resolveDateBackgroundColor;
  final DateColorResolver? resolveDateBorderColor;
  final DateMarkersResolver? resolveDateMarkers;
  final Color? iconBackgroundColor;
  final Color? iconColor;
  final Color? backgroundColor;

  const CalendarStyle({
    this.resolveDateTextColor,
    this.resolveDateBackgroundColor,
    this.resolveDateBorderColor,
    this.resolveDateMarkers,
    this.iconBackgroundColor,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  List<Object?> get props => [
    resolveDateTextColor,
    resolveDateBackgroundColor,
    resolveDateBorderColor,
    resolveDateMarkers,
    iconBackgroundColor,
    iconColor,
    backgroundColor,
  ];
}

class _CalendarStyleProvider extends InheritedWidget {
  final CalendarStyle calendarStyle;

  const _CalendarStyleProvider({required this.calendarStyle, required super.child});

  static CalendarStyle of(BuildContext context) {
    final _CalendarStyleProvider? result = context
        .dependOnInheritedWidgetOfExactType<_CalendarStyleProvider>();

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

  const _DateConstraintsProvider({required this.dateConstraints, required super.child});

  // ignore: unused_element
  static DateConstraints of(BuildContext context) {
    final _DateConstraintsProvider? result = context
        .dependOnInheritedWidgetOfExactType<_DateConstraintsProvider>();

    assert(result != null, 'No DateConstraintsProvider found in context');

    return result!.dateConstraints;
  }

  @override
  bool updateShouldNotify(_DateConstraintsProvider oldWidget) {
    return dateConstraints != oldWidget.dateConstraints;
  }
}

/// Управляет отображаемым месяцем [MonthCalendar] снаружи, например из собственного заголовка.
class MonthCalendarController extends ValueNotifier<DateTime> {
  MonthCalendarController(DateTime month) : super(month.monthStart);

  void goToMonth(DateTime month) => value = month.monthStart;

  void nextMonth() => value = value.addMonth(1);

  void previousMonth() => value = value.subtractMonth(1);
}

class MonthCalendar extends StatefulWidget {
  final DateTime? initialMonth;

  /// Внешнее управление месяцем. Если задан, `initialMonth` игнорируется.
  final MonthCalendarController? controller;

  /// Показывать ли встроенный заголовок с переключателями месяца.
  final bool showHeader;
  final OnDateTapCallback? onDateTap;
  final CalendarStyle? style;
  final DateConstraints? dateConstraints;
  final Widget? badgeWidget;
  final OnMonthChangeCallback? onChangeMonth;
  final CalendarHeaderBuilder? headerBuilder;

  const MonthCalendar({
    this.initialMonth,
    this.controller,
    this.showHeader = true,
    this.dateConstraints,
    this.onDateTap,
    this.style,
    this.badgeWidget,
    this.onChangeMonth,
    this.headerBuilder,
    super.key,
  });

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime selectedMonth =
      widget.controller?.value ?? widget.initialMonth ?? DateTime.now().monthStart;

  @override
  void initState() {
    super.initState();

    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(MonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);

    super.dispose();
  }

  void _onControllerChanged() {
    final month = widget.controller!.value;

    if (month == selectedMonth) {
      return;
    }

    setState(() {
      selectedMonth = month;
    });

    widget.onChangeMonth?.call(selectedMonth);
  }

  void _setMonth(DateTime month) {
    if (widget.controller != null) {
      // Источник правды — контроллер, состояние обновится в `_onControllerChanged`.
      widget.controller!.goToMonth(month);

      return;
    }

    setState(() {
      selectedMonth = month;

      widget.onChangeMonth?.call(selectedMonth);
    });
  }

  CalendarStyle get _defaultStyle =>
      CalendarStyle(resolveDateTextColor: (_) => context.uiPalette.ink);

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
            if (widget.showHeader) ...[
              const SizedBox(height: 8),
              widget.headerBuilder?.call(
                    selectedMonth,
                    _onNextMonthButtonHandler,
                    _onPreviousMonthButtonHandler,
                    _onNextYearButtonHandler,
                    _onPreviousYearButtonHandler,
                  ) ??
                  _DefaultCalendarHeader(
                    month: selectedMonth,
                    nextYearButtonHandler: _onNextYearButtonHandler,
                    previousYearButtonHandler: _onPreviousYearButtonHandler,
                    nextMonthButtonHandler: _onNextMonthButtonHandler,
                    previousMonthButtonHandler: _onPreviousMonthButtonHandler,
                  ),
              const SizedBox(height: 12),
            ],
            _CalendarBody(
              selectedMonth: selectedMonth,
              onDateTap: widget.onDateTap,
              badgeWidget: widget.badgeWidget,
            ),
          ],
        ),
      ),
    );
  }

  void _onNextYearButtonHandler() => _setMonth(selectedMonth.addYear(1));

  void _onPreviousYearButtonHandler() => _setMonth(selectedMonth.subtractYear(1));

  void _onNextMonthButtonHandler() => _setMonth(selectedMonth.addMonth(1));

  void _onPreviousMonthButtonHandler() => _setMonth(selectedMonth.subtractMonth(1));
}

class _DefaultCalendarHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback nextMonthButtonHandler;
  final VoidCallback previousMonthButtonHandler;
  final VoidCallback nextYearButtonHandler;
  final VoidCallback previousYearButtonHandler;

  const _DefaultCalendarHeader({
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
        .replaceAll(' г.', '')
        .toFirstLetterUpperCase();

    return Row(
      children: [
        Expanded(
          child: Text(
            formattedSelectedMonth,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.uiFonts.headline.copyWith(color: context.uiPalette.ink),
          ),
        ),
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

  const _CalendarHeaderButton({required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox.square(
        dimension: 44,
        child: Center(
          child: UiSvgImage(svgPath: iconPath, color: context.uiPalette.accent),
        ),
      ),
    );
  }
}

class _CalendarBody extends StatefulWidget {
  final DateTime selectedMonth;
  final OnDateTapCallback? onDateTap;
  final Widget? badgeWidget;

  const _CalendarBody({required this.selectedMonth, required this.onDateTap, this.badgeWidget});

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
      decoration: BoxDecoration(color: _backgroundColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Row(
              // Колонки совпадают с колонками дат; подпись уменьшается, если не помещается.
              children: daysOfWeek
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            day.toUpperCase(),
                            style: context.uiFonts.monoEyebrow.copyWith(
                              color: context.uiPalette.ink3,
                              fontSize: 12,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
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
        context.uiPalette.ink;
  }

  List<Color> get _markers {
    if (!widget.isActiveMonth) {
      return const [];
    }

    return _CalendarStyleProvider.of(context).resolveDateMarkers?.call(widget.date) ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isActiveMonth && widget.onTap != null ? () => widget.onTap!(widget.date) : null,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              height: 36,
              width: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _dateBackgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: _dateBorderColor, width: 2),
              ),
              duration: const Duration(milliseconds: 100),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 100),
                style: context.uiFonts.monoDigits.copyWith(
                  color: _dateTextColor,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(widget.date.day.toString()),
              ),
            ),
            const SizedBox(height: 2),
            _DateMarkers(colors: _markers),
          ],
        ),
      ),
    );
  }
}

/// Ряд маленьких точек под числом; занимает место и когда маркеров нет.
class _DateMarkers extends StatelessWidget {
  final List<Color> colors;

  const _DateMarkers({required this.colors});

  static const int _maxMarkers = 3;
  static const double _dotSize = 5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _dotSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final color in colors.take(_maxMarkers))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const SizedBox.square(dimension: _dotSize),
              ),
            ),
        ],
      ),
    );
  }
}

class _CalendarMonthData {
  final int year;
  final int month;

  const _CalendarMonthData({required this.year, required this.month});

  static const _daysInWeekCount = 7;

  int get _daysInMonth => DateUtils.getDaysInMonth(year, month);

  int get _weeksCount => ((_daysInMonth + _firstDayOffset) / _daysInWeekCount).ceil();

  int get _firstDayOffset => DateTime(year, month).weekday - 1;

  List<List<_CalendarDayData>> get weeks {
    final res = <List<_CalendarDayData>>[];
    final firstDayMonth = DateTime(year, month);
    DateTime firstDayOfWeek = firstDayMonth.subtract(Duration(days: _firstDayOffset));

    for (var weekIndex = 0; weekIndex < _weeksCount; weekIndex++) {
      final week = List<_CalendarDayData>.generate(_daysInWeekCount, (index) {
        final date = firstDayOfWeek.add(Duration(days: index));

        final isActiveMonth = date.year == year && date.month == month;

        return _CalendarDayData(
          date: date,
          isActiveMonth: isActiveMonth,
          isActiveDate: date.isToday,
        );
      });

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
