import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_grouped_list/ui_grouped_list.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_selectable_card/ui_selectable_card.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
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
    } catch (e, s) {
      TailsLogger.warning(
        'Не удалось загрузить сводку серии',
        source: 'EventDetailsSheet',
        error: e,
        stackTrace: s,
      );

      if (mounted && request == _statsRequest) {
        setState(() => _statsFailed = true);
      }
    }
  }

  void _close(EventDetailsResult result) => Navigator.of(context).pop(result);

  void _showDetails() => setState(() => _step = _Step.details);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: UiMotion.base,
      alignment: Alignment.topCenter,
      child: switch (_step) {
        _Step.details => _DetailsStep(
          key: const ValueKey('details'),
          occurrence: widget.occurrence,
          now: widget.now ?? DateTime.now(),
          petName: widget.petName,
          petAvatar: widget.petAvatar,
          onResult: _close,
          onOpenCancel: _openCancel,
        ),
        _Step.cancel => _CancelStep(
          key: ValueKey(_isSeries ? 'cancel-series' : 'cancel-single'),
          occurrence: widget.occurrence,
          stats: _stats,
          statsFailed: _statsFailed,
          scope: _scope,
          onScopeChanged: (scope) => setState(() => _scope = scope),
          onRetry: _loadStats,
          onBack: _showDetails,
          onConfirm: (scope) => _close(EventDetailsResult$Cancel(scope)),
        ),
      },
    );
  }
}

/// Первый шаг: шапка события, строки «Когда» и «Повтор», доступные действия.
class _DetailsStep extends StatelessWidget {
  const _DetailsStep({
    required this.occurrence,
    required this.now,
    required this.onResult,
    required this.onOpenCancel,
    this.petName,
    this.petAvatar,
    super.key,
  });

  final ScheduleEventModel occurrence;
  final DateTime now;
  final String? petName;
  final Widget? petAvatar;
  final ValueChanged<EventDetailsResult> onResult;
  final VoidCallback onOpenCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final rule = occurrence.recurrence;
    final description = (occurrence.description ?? '').trim();

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
                dimension: UiSpacing.x12,
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
                    _statusText(l10n),
                    style: fonts.footnote.copyWith(
                      color: occurrence.status.isCancelled ? palette.danger : palette.ink2,
                    ),
                  ),
                ],
              ),
            ),
            if (petAvatar != null) ...[const SizedBox(width: UiSpacing.x3), petAvatar!],
          ],
        ),
        if (petName != null) ...[
          const SizedBox(height: UiSpacing.x2),
          Text(
            '${occurrence.type.getLocalizedName(l10n)} · $petName',
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
        if (description.isNotEmpty) ...[
          const SizedBox(height: UiSpacing.x3),
          Text(description, style: fonts.body.copyWith(color: palette.ink)),
        ],
        const SizedBox(height: UiSpacing.x5),
        for (final action in EventActionRules.available(occurrence)) ...[
          _ActionButton(action: action, onResult: onResult, onOpenCancel: onOpenCancel),
          const SizedBox(height: UiSpacing.x3),
        ],
      ],
    );
  }

  String _statusText(AppLocalizations l10n) {
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
}

/// Кнопка одного из действий над вхождением.
class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.action, required this.onResult, required this.onOpenCancel});

  final EventAction action;
  final ValueChanged<EventDetailsResult> onResult;
  final VoidCallback onOpenCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;

    return switch (action) {
      EventAction.restore => UiButton.main(
        label: l10n.eventDetailsRestore,
        onPressed: () => onResult(const EventDetailsResult$Restore()),
      ),
      EventAction.unmarkDone => UiButton.secondary(
        label: l10n.eventDetailsUnmark,
        onPressed: () => onResult(const EventDetailsResult$Unmark()),
      ),
      EventAction.cancel => UiButton.main(
        label: l10n.eventDetailsCancelAction,
        staticFillColor: palette.dangerTint,
        staticItemColor: palette.danger,
        pressedFillColor: palette.dangerTint,
        pressedItemColor: palette.danger,
        onPressed: onOpenCancel,
      ),
      EventAction.edit => UiButton.secondary(
        label: l10n.eventDetailsEdit,
        onPressed: () => onResult(const EventDetailsResult$Edit()),
      ),
    };
  }
}

/// Второй шаг: подтверждение отмены одиночного события либо выбор области у серии.
class _CancelStep extends StatelessWidget {
  const _CancelStep({
    required this.occurrence,
    required this.stats,
    required this.statsFailed,
    required this.scope,
    required this.onScopeChanged,
    required this.onRetry,
    required this.onBack,
    required this.onConfirm,
    super.key,
  });

  final ScheduleEventModel occurrence;
  final SeriesStats? stats;
  final bool statsFailed;
  final OccurrenceScope scope;
  final ValueChanged<OccurrenceScope> onScopeChanged;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final ValueChanged<OccurrenceScope> onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final loaded = stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        UiSheetHeader.back(
          title: l10n.eventCancelSheetTitle,
          backLabel: l10n.eventDetailsBack,
          onCancel: onBack,
        ),
        const SizedBox(height: UiSpacing.x3),
        if (occurrence.recurrence == null) ...[
          Text(l10n.eventCancelSheetSingleText, style: fonts.body.copyWith(color: palette.ink2)),
          const SizedBox(height: UiSpacing.x5),
          _ConfirmButton(
            label: l10n.eventCancelConfirmOne,
            onPressed: () => onConfirm(OccurrenceScope.one),
          ),
        ] else if (statsFailed) ...[
          Text(l10n.eventCancelStatsLoadFailed, style: fonts.body.copyWith(color: palette.danger)),
          const SizedBox(height: UiSpacing.x4),
          UiButton.secondary(label: l10n.eventActionRetry, onPressed: onRetry),
        ] else if (loaded == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: UiSpacing.x8),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          _SeriesChoice(
            texts: CancelScopeTexts(l10n, date: occurrence.date, stats: loaded),
            scope: scope,
            onScopeChanged: onScopeChanged,
            onConfirm: onConfirm,
          ),
      ],
    );
  }
}

/// Выбор области отмены у серии: только эта дата или эта и все следующие.
class _SeriesChoice extends StatelessWidget {
  const _SeriesChoice({
    required this.texts,
    required this.scope,
    required this.onScopeChanged,
    required this.onConfirm,
  });

  final CancelScopeTexts texts;
  final OccurrenceScope scope;
  final ValueChanged<OccurrenceScope> onScopeChanged;
  final ValueChanged<OccurrenceScope> onConfirm;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    if (texts.isSingleChoice) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(texts.lastInSeriesHint!, style: fonts.body.copyWith(color: palette.ink2)),
          const SizedBox(height: UiSpacing.x5),
          _ConfirmButton(label: texts.confirmOne, onPressed: () => onConfirm(OccurrenceScope.one)),
        ],
      );
    }

    final future = scope == OccurrenceScope.future;
    final hint = future ? texts.futureHint : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.eventCancelSheetSeriesText, style: fonts.body.copyWith(color: palette.ink2)),
        const SizedBox(height: UiSpacing.x3),
        UiSelectableCard(
          label: texts.oneLabel,
          selected: !future,
          onTap: () => onScopeChanged(OccurrenceScope.one),
        ),
        const SizedBox(height: UiSpacing.x2),
        UiSelectableCard(
          label: texts.futureLabel,
          selected: future,
          onTap: () => onScopeChanged(OccurrenceScope.future),
        ),
        if (hint != null) ...[
          const SizedBox(height: UiSpacing.x3),
          Text(hint, style: fonts.footnote.copyWith(color: palette.ink2)),
        ],
        const SizedBox(height: UiSpacing.x5),
        _ConfirmButton(
          label: future ? texts.confirmFuture : texts.confirmOne,
          onPressed: () => onConfirm(scope),
        ),
      ],
    );
  }
}

/// Красная кнопка подтверждения отмены.
class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return UiButton.main(
      label: label,
      staticFillColor: palette.dangerTint,
      staticItemColor: palette.danger,
      pressedFillColor: palette.dangerTint,
      pressedItemColor: palette.danger,
      onPressed: onPressed,
    );
  }
}
