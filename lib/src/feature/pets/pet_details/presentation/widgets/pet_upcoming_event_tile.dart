import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_event_tile/ui_event_tile.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_avatar/ui_pet_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/event_day_label.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/mark_done/mark_done_bloc.dart';

/// Событие питомца в карточке: [UiEventTile] с отметкой выполнения.
class PetUpcomingEventTile extends StatefulWidget {
  const PetUpcomingEventTile({
    required this.event,
    required this.petImage,
    required this.petColor,
    super.key,
  });

  final ScheduleEventModel event;
  final String petImage;
  final Color petColor;

  @override
  State<PetUpcomingEventTile> createState() => _PetUpcomingEventTileState();
}

class _PetUpcomingEventTileState extends State<PetUpcomingEventTile> {
  late final MarkDoneBloc _markDoneBloc = MarkDoneBloc(
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
  );

  late bool _done = widget.event.done;

  @override
  void dispose() {
    _markDoneBloc.close();
    super.dispose();
  }

  void _toggle() {
    final value = !_done;

    setState(() => _done = value);

    _markDoneBloc.add(
      MarkDoneEvent.markDoneRequested(
        value: value,
        eventId: widget.event.id,
        date: widget.event.date,
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

    return BlocListener<MarkDoneBloc, MarkDoneState>(
      bloc: _markDoneBloc,
      listener: (context, state) {
        state.mapOrNull(
          error: (_) {
            setState(() => _done = !_done);

            showUiSnackBar(context, message: l10n.tryLater);
          },
        );
      },
      child: UiEventTile(
        title: event.title,
        subtitle: '$when · ${event.type.getLocalizedName(l10n)}',
        typeIcon: event.type.icon,
        stripeColor: widget.petColor,
        leading: UiPetAvatar(imageUrl: widget.petImage),
        isDone: _done,
        onToggle: _toggle,
      ),
    );
  }
}
