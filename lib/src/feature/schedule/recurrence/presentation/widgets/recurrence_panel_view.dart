import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_wheel_panel/ui_wheel_panel.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_panel.dart';

/// Нижняя панель с барабаном для открытой [RecurrencePanel]: время, дата года или дата окончания.
///
/// Время и дата окончания меняют черновик сразу при прокрутке (итог обновляется вживую);
/// даты года применяются кнопкой («Добавить» / «Применить»).
class RecurrencePanelView extends StatefulWidget {
  const RecurrencePanelView({
    required this.panel,
    required this.draft,
    required this.onChanged,
    required this.onPanel,
    super.key,
  });

  static const int _hours = 24;
  static const int _minutes = 60;
  static const int _minuteStep = 5;
  static const int _monthsInYear = 12;
  static const int _yearsAhead = 30;

  final RecurrencePanel panel;
  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;

  /// Сменить открытую панель или закрыть (`null`).
  final ValueChanged<RecurrencePanel?> onPanel;

  @override
  State<RecurrencePanelView> createState() => _RecurrencePanelViewState();
}

class _RecurrencePanelViewState extends State<RecurrencePanelView> {
  /// Выбранная дата в барабане года: ещё не применена.
  late YearDate _pending = _initialPending();

  YearDate _initialPending() {
    final panel = widget.panel;
    if (panel is RecurrencePanel$YearDate) {
      final date = panel.date;

      return date ?? YearDate(widget.draft.eventDate.month, widget.draft.eventDate.day);
    }

    return const YearDate(1, 1);
  }

  void _close() => widget.onPanel(null);

  /// Число дней месяца для дат без года (февраль — 29, правило допускает 29 февраля).
  static int _yearDateDays(int month) => switch (month) {
    2 => 29,
    4 || 6 || 9 || 11 => 30,
    _ => 31,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = widget.draft;

    switch (widget.panel) {
      case RecurrencePanel$Time(:final index):
        if (index >= draft.times.length) {
          return const SizedBox.shrink();
        }
        final time = draft.times[index];
        // Минуты с шагом 5; если время события «нестандартное» (17:03), оно тоже есть в списке.
        final minutes = {
          for (var m = 0; m < RecurrencePanelView._minutes; m += RecurrencePanelView._minuteStep) m,
          time.minute,
        }.toList()..sort();
        void change(LocalTime value) {
          final next = draft.withTimeAt(index, value);
          widget.onChanged(next);
          widget.onPanel(RecurrencePanel.time(next.times.indexOf(value)));
        }

        return UiWheelPanel(
          title: l10n.recurrenceTimeN(index + 1),
          separator: ':',
          leftLabel: draft.times.length > 1 ? l10n.recurrenceDelete : null,
          leftIsDestructive: true,
          onLeft: () {
            widget.onChanged(draft.removeTimeAt(index));
            _close();
          },
          rightLabel: l10n.recurrenceApply,
          onRight: _close,
          columns: [
            UiWheelColumn(
              labels: [
                for (var h = 0; h < RecurrencePanelView._hours; h++) h.toString().padLeft(2, '0'),
              ],
              selectedIndex: time.hour,
              alignment: Alignment.centerRight,
              onSelected: (hour) => change(LocalTime(hour, time.minute)),
            ),
            UiWheelColumn(
              labels: [for (final m in minutes) m.toString().padLeft(2, '0')],
              selectedIndex: minutes.indexOf(time.minute),
              alignment: Alignment.centerLeft,
              onSelected: (index) => change(LocalTime(time.hour, minutes[index])),
            ),
          ],
        );

      case RecurrencePanel$YearDate(:final date):
        final isNew = date == null;

        return UiWheelPanel(
          title: isNew ? l10n.recurrenceNewDate : l10n.recurrenceDateTitle,
          leftLabel: isNew
              ? l10n.cancel
              : (draft.yearDates.length > 1 ? l10n.recurrenceDelete : null),
          leftIsDestructive: !isNew,
          onLeft: () {
            if (!isNew) {
              widget.onChanged(draft.toggleYearDate(date));
            }
            _close();
          },
          rightLabel: isNew ? l10n.recurrenceAdd : l10n.recurrenceApply,
          onRight: () {
            widget.onChanged(
              isNew ? draft.toggleYearDate(_pending) : draft.replaceYearDate(date, _pending),
            );
            _close();
          },
          columns: [
            UiWheelColumn(
              labels: [for (var d = 1; d <= _yearDateDays(_pending.month); d++) '$d'],
              selectedIndex: _pending.day - 1,
              alignment: Alignment.centerRight,
              onSelected: (index) => setState(() => _pending = YearDate(_pending.month, index + 1)),
            ),
            UiWheelColumn(
              flex: 2,
              labels: [
                for (var m = 1; m <= RecurrencePanelView._monthsInYear; m++)
                  l10n.recurrenceMonthGenitive('$m'),
              ],
              selectedIndex: _pending.month - 1,
              alignment: Alignment.centerLeft,
              onSelected: (index) => setState(() {
                final month = index + 1;
                _pending = YearDate(month, _pending.day.clamp(1, _yearDateDays(month)));
              }),
            ),
          ],
        );

      case RecurrencePanel$EndDate():
        final end = draft.end;
        if (end is! RecurrenceEnd$Until) {
          return const SizedBox.shrink();
        }
        final firstYear = draft.eventDate.year;
        final lastYear = firstYear + RecurrencePanelView._yearsAhead;
        final year = end.date.year.clamp(firstYear, lastYear);
        final daysInMonth = DateUtils.getDaysInMonth(year, end.date.month);
        void change(int y, int m, int d) => widget.onChanged(
          draft.withEnd(
            RecurrenceEnd.until(DateTime(y, m, d.clamp(1, DateUtils.getDaysInMonth(y, m)))),
          ),
        );

        return UiWheelPanel(
          title: l10n.recurrenceEndDateTitle,
          rightLabel: l10n.recurrenceApply,
          onRight: _close,
          columns: [
            UiWheelColumn(
              labels: [for (var d = 1; d <= daysInMonth; d++) '$d'],
              selectedIndex: end.date.day.clamp(1, daysInMonth) - 1,
              alignment: Alignment.centerRight,
              onSelected: (index) => change(year, end.date.month, index + 1),
            ),
            UiWheelColumn(
              flex: 2,
              labels: [
                for (var m = 1; m <= RecurrencePanelView._monthsInYear; m++)
                  l10n.recurrenceMonthGenitive('$m'),
              ],
              selectedIndex: end.date.month - 1,
              onSelected: (index) => change(year, index + 1, end.date.day),
            ),
            UiWheelColumn(
              labels: [for (var y = firstYear; y <= lastYear; y++) '$y'],
              selectedIndex: year - firstYear,
              alignment: Alignment.centerLeft,
              onSelected: (index) => change(firstYear + index, end.date.month, end.date.day),
            ),
          ],
        );
    }
  }
}
