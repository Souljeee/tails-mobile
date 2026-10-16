import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_selectable_card/ui_selectable_card.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_status.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/series_stats.dart';
import 'package:tails_mobile/src/feature/schedule/event_details/domain/occurrence_when.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/cancel_scope_texts.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/event_action_rules.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_summary.dart';

/// Что пользователь выбрал в шите деталей. Само действие выполняет вызывающий экран.
sealed class EventDetailsResult {
  const EventDetailsResult();
}

/// Отменить вхождение (при серии — с выбранной областью).
final class EventDetailsResult$Cancel extends EventDetailsResult {
  const EventDetailsResult$Cancel(this.scope);

  final OccurrenceScope scope;
}

/// Вернуть отменённое событие в расписание.
final class EventDetailsResult$Restore extends EventDetailsResult {
  const EventDetailsResult$Restore();
}

/// Открыть форму редактирования.
final class EventDetailsResult$Edit extends EventDetailsResult {
  const EventDetailsResult$Edit();
}

/// Снять отметку о выполнении.
final class EventDetailsResult$Unmark extends EventDetailsResult {
  const EventDetailsResult$Unmark();
}

/// Открывает шит деталей. [loadStats] запрашивает сводку серии для шага отмены.
Future<EventDetailsResult?> showEventDetailsSheet({
  required BuildContext context,
  required ScheduleEventModel occurrence,
  required Future<SeriesStats> Function() loadStats,
  String? petName,
  Widget? petAvatar,
  DateTime? now,
}) => showUiBottomSheet<EventDetailsResult>(
  context: context,
  name: 'event-details',
  builder: (_) => EventDetailsSheet(
    occurrence: occurrence,
    loadStats: loadStats,
    petName: petName,
    petAvatar: petAvatar,
    now: now,
  ),
);

enum _Step { details, cancel }

/// Шит деталей вхождения: «Детали» → «Отменить событие» (одиночное или выбор области).
class EventDetailsSheet extends StatefulWidget {
  const EventDetailsSheet({
    required this.occurrence,
    required this.loadStats,
    this.petName,
    this.petAvatar,
    this.now,
    super.key,
  });

  final ScheduleEventModel occurrence;
  final Future<SeriesStats> Function() loadStats;
  final String? petName;
  final Widget? petAvatar;

  /// Текущий момент (для «Сегодня / Завтра»); в тестах подставляется.
  final DateTime? now;

  @override
  State<EventDetailsSheet> createState() => _EventDetailsSheetState();
}

class _EventDetailsSheetState extends State<EventDetailsSheet> {
  _Step _step = _Step.details;
  OccurrenceScope _scope = OccurrenceScope.one;
  SeriesStats? _stats;
  bool _statsFailed = false;

  /// Номер запроса сводки: ответ устаревшего запроса (после «Назад» или повтора) отбрасывается.
  int _statsRequest = 0;

  bool get _isSeries => widget.occurrence.recurrence != null;

  void _openCancel() {
    setState(() {
      _step = _Step.cancel;
    });

    if (_isSeries && _stats == null) {
      unawaited(_loadStats());
    }
  }

  Future<void> _loadStats() async {
    final request = ++_statsRequest;

    setState(() => _statsFailed = false);

    try {
      final stats = await widget.loadStats();

      if (mounted && request == _statsRequest) {
        setState(() => _stats = stats);
      }
    } catch (_) {
      if (mounted && request == _statsRequest) {
        setState(() => _statsFailed = true);
      }
    }
  }

  void _close(EventDetailsResult result) => Navigator.of(context).pop(result);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: switch (_step) {
        _Step.details => _buildDetails(context),
        _Step.cancel => _buildCancel(context),
      },
    );
  }

  Widget _buildDetails(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final occurrence = widget.occurrence;
    final now = widget.now ?? DateTime.now();
    final rule = occurrence.recurrence;
    final actions = EventActionRules.available(occurrence);

    final when = formatOccurrenceWhen(
      l10n: l10n,
      date: occurrence.date,
      now: now,
      time: occurrence.time,
    );
    final repeat = rule == null
        ? l10n.eventDetailsNoRepeat
        : RecurrenceSummaryBuilder(
            l10n,
          ).build(rule, start: occurrence.date, eventTime: occurrence.time).title;

    return Column(
      key: const ValueKey('details'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        UiSheetHeader(title: '', cancelLabel: l10n.eventDetailsClose),
        const SizedBox(height: UiSpacing.x2),
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: palette.accentTint, borderRadius: UiRadius.smAll),
              child: SizedBox.square(
                dimension: 48,
                child: Icon(occurrence.type.icon, color: palette.accent),
              ),
            ),
            const SizedBox(width: UiSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      occurrence.title,
                      style: fonts.displayS.copyWith(color: palette.ink),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusText(context),
                    style: fonts.footnote.copyWith(
                      color: occurrence.status.isCancelled ? palette.danger : palette.ink2,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.petAvatar != null) ...[
              const SizedBox(width: UiSpacing.x3),
              widget.petAvatar!,
            ],
          ],
        ),
        if (widget.petName != null) ...[
          const SizedBox(height: UiSpacing.x2),
          Text(
            '${occurrence.type.getLocalizedName(l10n)} · ${widget.petName}',
            style: fonts.body.copyWith(color: palette.ink2),
          ),
        ],
        const SizedBox(height: UiSpacing.x4),
        UiGroupedList(
          dividerIndent: UiInfoRow.leadingWidth,
          children: [
            UiInfoRow(icon: Icons.schedule_rounded, label: l10n.eventDetailsWhenLabel, value: when),
            UiInfoRow(
              icon: Icons.repeat_rounded,
              label: l10n.eventDetailsRepeatLabel,
              value: repeat,
            ),
          ],
        ),
        if ((occurrence.description ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: UiSpacing.x3),
          Text(occurrence.description!.trim(), style: fonts.body.copyWith(color: palette.ink)),
        ],
        const SizedBox(height: UiSpacing.x5),
        for (final action in actions) ...[
          _actionButton(context, action),
          const SizedBox(height: UiSpacing.x3),
        ],
      ],
    );
  }

  String _statusText(BuildContext context) {
    final l10n = context.l10n;
    final occurrence = widget.occurrence;

    return switch (occurrence.status) {
      ScheduleEventStatus.scheduled => l10n.eventDetailsStatusScheduled,
      ScheduleEventStatus.cancelled => l10n.eventStatusCancelled,
      ScheduleEventStatus.done =>
        occurrence.doneAt == null
            ? l10n.eventDetailsStatusDoneNoTime
            : l10n.eventDetailsStatusDone(
                '${occurrence.doneAt!.hour.toString().padLeft(2, '0')}:'
                '${occurrence.doneAt!.minute.toString().padLeft(2, '0')}',
              ),
    };
  }

  Widget _actionButton(BuildContext context, EventAction action) {
    final l10n = context.l10n;
    final palette = context.uiPalette;

    switch (action) {
      case EventAction.restore:
        return UiButton.main(
          label: l10n.eventDetailsRestore,
          onPressed: () => _close(const EventDetailsResult$Restore()),
        );
      case EventAction.unmarkDone:
        return UiButton.secondary(
          label: l10n.eventDetailsUnmark,
          onPressed: () => _close(const EventDetailsResult$Unmark()),
        );
      case EventAction.cancel:
        return UiButton.main(
          label: l10n.eventDetailsCancelAction,
          staticFillColor: palette.dangerTint,
          staticItemColor: palette.danger,
          pressedFillColor: palette.dangerTint,
          pressedItemColor: palette.danger,
          onPressed: _openCancel,
        );
      case EventAction.edit:
        return UiButton.secondary(
          label: l10n.eventDetailsEdit,
          onPressed: () => _close(const EventDetailsResult$Edit()),
        );
    }
  }

  Widget _buildCancel(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    final header = UiSheetHeader.back(
      title: l10n.eventCancelSheetTitle,
      backLabel: l10n.eventDetailsBack,
      onCancel: () => setState(() => _step = _Step.details),
    );

    if (!_isSeries) {
      return Column(
        key: const ValueKey('cancel-single'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          const SizedBox(height: UiSpacing.x3),
          Text(l10n.eventCancelSheetSingleText, style: fonts.body.copyWith(color: palette.ink2)),
          const SizedBox(height: UiSpacing.x5),
          _confirmButton(context, l10n.eventCancelConfirmOne, OccurrenceScope.one),
        ],
      );
    }

    final stats = _stats;

    return Column(
      key: const ValueKey('cancel-series'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        const SizedBox(height: UiSpacing.x3),
        if (_statsFailed) ...[
          Text(l10n.eventCancelStatsLoadFailed, style: fonts.body.copyWith(color: palette.danger)),
          const SizedBox(height: UiSpacing.x4),
          UiButton.secondary(label: l10n.eventActionRetry, onPressed: _loadStats),
        ] else if (stats == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: UiSpacing.x8),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          ..._seriesChoice(context, stats),
      ],
    );
  }

  List<Widget> _seriesChoice(BuildContext context, SeriesStats stats) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final texts = CancelScopeTexts(l10n, date: widget.occurrence.date, stats: stats);

    if (texts.isSingleChoice) {
      return [
        Text(texts.lastInSeriesHint!, style: fonts.body.copyWith(color: palette.ink2)),
        const SizedBox(height: UiSpacing.x5),
        _confirmButton(context, texts.confirmOne, OccurrenceScope.one),
      ];
    }

    final future = _scope == OccurrenceScope.future;
    final hint = future ? texts.futureHint : null;

    return [
      Text(l10n.eventCancelSheetSeriesText, style: fonts.body.copyWith(color: palette.ink2)),
      const SizedBox(height: UiSpacing.x3),
      UiSelectableCard(
        label: texts.oneLabel,
        selected: !future,
        onTap: () => setState(() => _scope = OccurrenceScope.one),
      ),
      const SizedBox(height: UiSpacing.x2),
      UiSelectableCard(
        label: texts.futureLabel,
        selected: future,
        onTap: () => setState(() => _scope = OccurrenceScope.future),
      ),
      if (hint != null) ...[
        const SizedBox(height: UiSpacing.x3),
        Text(hint, style: fonts.footnote.copyWith(color: palette.ink2)),
      ],
      const SizedBox(height: UiSpacing.x5),
      _confirmButton(context, future ? texts.confirmFuture : texts.confirmOne, _scope),
    ];
  }

  Widget _confirmButton(BuildContext context, String label, OccurrenceScope scope) {
    final palette = context.uiPalette;

    return UiButton.main(
      label: label,
      staticFillColor: palette.dangerTint,
      staticItemColor: palette.danger,
      pressedFillColor: palette.dangerTint,
      pressedItemColor: palette.danger,
      onPressed: () => _close(EventDetailsResult$Cancel(scope)),
    );
  }
}
