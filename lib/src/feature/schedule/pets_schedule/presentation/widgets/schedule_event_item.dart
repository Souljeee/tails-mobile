import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_event_tile/ui_event_tile.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_avatar/ui_pet_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/mark_done/mark_done_bloc.dart';

/// Строка события дня: слева время, справа карточка [UiEventTile].
class ScheduleEventItem extends StatefulWidget {
  final ScheduleEventModel event;
  final PetModel? pet;

  /// Цвет питомца для полосы слева.
  final Color petColor;
  final ValueChanged<bool>? onToggle;

  const ScheduleEventItem({
    required this.event,
    required this.petColor,
    this.pet,
    this.onToggle,
    super.key,
  });

  @override
  State<ScheduleEventItem> createState() => _ScheduleEventItemState();
}

class _ScheduleEventItemState extends State<ScheduleEventItem> {
  static const double _timeColumnWidth = 56;

  late final MarkDoneBloc _markDoneBloc = MarkDoneBloc(
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
  );

  @override
  void dispose() {
    _markDoneBloc.close();
    super.dispose();
  }

  void _toggle() {
    widget.onToggle?.call(!widget.event.done);

    _markDoneBloc.add(
      MarkDoneEvent.markDoneRequested(
        value: !widget.event.done,
        eventId: widget.event.id,
        date: widget.event.date,
        time: widget.event.time,
        timeZoneOffset: widget.event.timeZoneOffset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final event = widget.event;
    final typeName = event.type.getLocalizedName(l10n);
    final subtitle = widget.pet == null ? typeName : '$typeName · ${widget.pet!.name}';
    final time = event.time;

    return BlocListener<MarkDoneBloc, MarkDoneState>(
      bloc: _markDoneBloc,
      listener: (context, state) {
        state.mapOrNull(
          error: (state) {
            widget.onToggle?.call(!widget.event.done);

            showUiSnackBar(context, message: l10n.tryLater);
          },
        );
      },
      child: Row(
        children: [
          SizedBox(
            width: _timeColumnWidth,
            child: Text(
              time == null ? l10n.scheduleAllDay : time.substring(0, 5),
              style: context.uiFonts.monoMeta.copyWith(color: palette.ink2),
            ),
          ),
          const SizedBox(width: UiSpacing.x2),
          Expanded(
            child: UiEventTile(
              title: event.title,
              subtitle: subtitle,
              typeIcon: event.type.icon,
              stripeColor: widget.petColor,
              leading: UiPetAvatar(
                imageUrl: widget.pet?.image,
                placeholderAsset: widget.pet?.petType.emptyAvatarAsset,
              ),
              isDone: event.done,
              onToggle: _toggle,
            ),
          ),
        ],
      ),
    );
  }
}
