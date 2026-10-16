import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_event_tile/ui_event_tile.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_avatar/ui_pet_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/event_day_label.dart';
import 'package:tails_mobile/src/feature/schedule/core/analytics/schedule_analytics.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/event_details/presentation/cancel_snack_bars.dart';
import 'package:tails_mobile/src/feature/schedule/event_details/presentation/event_details_sheet.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/event_actions/event_actions_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/mark_done/mark_done_bloc.dart';

/// Событие питомца в карточке: [UiEventTile] с отметкой выполнения.
class PetUpcomingEventTile extends StatefulWidget {
  const PetUpcomingEventTile({
    required this.event,
    required this.petImage,
    required this.petType,
    required this.petColor,
    this.petName,
    this.onChanged,
    super.key,
  });

  final ScheduleEventModel event;
  final String? petImage;
  final PetTypeEnum petType;
  final Color petColor;
  final String? petName;

  /// Список событий изменился на сервере (отмена серии): карточку питомца стоит перезагрузить.
  final VoidCallback? onChanged;

  @override
  State<PetUpcomingEventTile> createState() => _PetUpcomingEventTileState();
}

class _PetUpcomingEventTileState extends State<PetUpcomingEventTile> {
  late final MarkDoneBloc _markDoneBloc = MarkDoneBloc(
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
  );

  late final EventActionsBloc _actionsBloc = EventActionsBloc(
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
  );

  late bool _done = widget.event.done;

  /// Вхождение отменено: на экране питомца отменённые события скрываются.
  bool _cancelled = false;

  @override
  void dispose() {
    _markDoneBloc.close();
    // Закрытие блока отправляет ожидающую отмену.
    _actionsBloc.close();
    super.dispose();
  }

  ScheduleEventModel get _occurrence => widget.event.copyWith(done: CopyWithWrapper.value(_done));

  Future<void> _openDetails() async {
    final repository = DependenciesScope.of(context).scheduleRepository;
    final event = _occurrence;

    final result = await showEventDetailsSheet(
      context: context,
      occurrence: event,
      loadStats: () => repository.getSeriesStats(event.ref),
      petName: widget.petName,
      petAvatar: UiPetAvatar(
        imageUrl: widget.petImage,
        placeholderAsset: widget.petType.emptyAvatarAsset,
      ),
    );

    if (!mounted) {
      return;
    }

    switch (result) {
      case EventDetailsResult$Cancel(:final scope):
        _actionsBloc.add(EventActionsEvent.cancelRequested(occurrence: event, scope: scope));
      case EventDetailsResult$Unmark():
        if (_done) {
          _toggle();
        }
      case EventDetailsResult$Restore():
      case null:
        break;
    }
  }

  void _onActionEffect(EventActionsState state) {
    final effect = state.effect;

    switch (effect) {
      case final EventActionEffect$CancelApplied applied:
        setState(() => _cancelled = true);
        showCancelUndoSnackBar(context, bloc: _actionsBloc, effect: applied);
      case EventActionEffect$CancelUndone():
        setState(() => _cancelled = false);
      case final EventActionEffect$CancelFailed failed:
        setState(() => _cancelled = false);
        showCancelFailedSnackBar(context, bloc: _actionsBloc, effect: failed);
      case EventActionEffect$CancelCommitted(:final scope):
        // Отмена серии убрала следующие вхождения: перечитываем ближайшие события.
        if (scope == OccurrenceScope.future) {
          widget.onChanged?.call();
        }
      case EventActionEffect$RestoreApplied():
      case EventActionEffect$RestoreCommitted():
      case EventActionEffect$RestoreFailed():
      case null:
        break;
    }
  }

  void _toggle() {
    final value = !_done;

    setState(() => _done = value);

    _markDoneBloc.add(
      MarkDoneEvent.markDoneRequested(
        value: value,
        eventId: widget.event.id,
        date: widget.event.date,
        time: widget.event.time,
        timeZoneOffset: widget.event.timeZoneOffset,
        analyticsEventType: ScheduleAnalytics.eventType(widget.event.type),
        analyticsIsRecurring: widget.event.recurrence != null,
        analyticsFrom: 'pet_details',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final event = widget.event;
    final time = event.time;
    final day = formatEventDayLabel(
      l10n: l10n,
      locale: Localizations.localeOf(context).toString(),
      date: event.date,
      now: DateTime.now(),
      isAllDay: time == null,
    );
    final when = time == null ? day : '$day, ${time.substring(0, 5)}';

    if (_cancelled) {
      return BlocListener<EventActionsBloc, EventActionsState>(
        bloc: _actionsBloc,
        listenWhen: (previous, current) => previous.effect != current.effect,
        listener: (context, state) => _onActionEffect(state),
        child: const SizedBox.shrink(),
      );
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<EventActionsBloc, EventActionsState>(
          bloc: _actionsBloc,
          listenWhen: (previous, current) => previous.effect != current.effect,
          listener: (context, state) => _onActionEffect(state),
        ),
        BlocListener<MarkDoneBloc, MarkDoneState>(
          bloc: _markDoneBloc,
          listener: (context, state) {
            state.mapOrNull(
              error: (_) {
                setState(() => _done = !_done);

                showUiSnackBar(context, message: l10n.tryLater);
              },
            );
          },
        ),
      ],
      child: UiEventTile(
        title: event.title,
        subtitle: '$when · ${event.type.getLocalizedName(l10n)}',
        typeIcon: event.type.icon,
        stripeColor: widget.petColor,
        leading: UiPetAvatar(
          imageUrl: widget.petImage,
          placeholderAsset: widget.petType.emptyAvatarAsset,
        ),
        status: _done ? UiEventTileStatus.done : UiEventTileStatus.scheduled,
        isRecurring: event.recurrence != null,
        toggleLabel: _done ? l10n.eventToggleUndone : l10n.eventToggleDone,
        detailsLabel: l10n.eventOpenDetails,
        onToggle: _toggle,
        onTap: _openDetails,
      ),
    );
  }
}
