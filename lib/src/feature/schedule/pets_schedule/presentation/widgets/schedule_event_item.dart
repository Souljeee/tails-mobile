import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_checkbox/ui_checkbox.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/mark_done/mark_done_bloc.dart';

const int _animationMiliseconds = 300;

class ScheduleEventItem extends StatefulWidget {
  final ScheduleEventModel event;
  final PetModel? pet;
  final void Function(bool value)? onToggle;

  const ScheduleEventItem({required this.event, this.pet, this.onToggle, super.key});

  @override
  State<ScheduleEventItem> createState() => _ScheduleEventItemState();
}

class _ScheduleEventItemState extends State<ScheduleEventItem> {
  late final MarkDoneBloc _markDoneBloc = MarkDoneBloc(
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
  );

  @override
  void dispose() {
    _markDoneBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MarkDoneBloc, MarkDoneState>(
      bloc: _markDoneBloc,
      listener: (context, state) {
        state.mapOrNull(
          error: (state) {
            widget.onToggle?.call(!widget.event.done);

            _showErrorSnackBar();
          },
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: _animationMiliseconds),
        decoration: BoxDecoration(
          color: widget.event.done ? context.uiColors.black5 : context.uiColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: widget.event.done
              ? [
                  BoxShadow(
                    color: context.uiColors.black30,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            spacing: 16,
            children: [
              _ScheduleAvatar(type: widget.event.type, done: widget.event.done),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      style: widget.event.done
                          ? context.uiFonts.text16Semibold.copyWith(
                              color: context.uiColors.black60,
                              decoration: TextDecoration.lineThrough,
                            )
                          : context.uiFonts.text16Semibold.copyWith(
                              color: context.uiColors.black100,
                            ),
                      duration: const Duration(milliseconds: _animationMiliseconds),
                      child: Text(widget.event.title),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.event.time != null) ...[
                          AnimatedDefaultTextStyle(
                            style: widget.event.done
                                ? context.uiFonts.text14Regular.copyWith(
                                    color: context.uiColors.black40,
                                  )
                                : context.uiFonts.text14Regular.copyWith(
                                    color: context.uiColors.orangePrimary,
                                  ),
                            duration: const Duration(milliseconds: _animationMiliseconds),
                            child: Text(widget.event.time!.substring(0, 5)),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (widget.pet != null)
                          Text(widget.pet!.name, style: context.uiFonts.text14Regular),
                      ],
                    ),
                  ],
                ),
              ),
              UiCheckbox(
                isChecked: widget.event.done,
                onTap: () {
                  widget.onToggle?.call(!widget.event.done);

                  _markDoneBloc.add(
                    MarkDoneEvent.markDoneRequested(
                      value: !widget.event.done,
                      eventId: widget.event.id,
                      date: widget.event.date,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.tryLater,
          style: context.uiFonts.text14Regular.copyWith(color: context.uiColors.white),
        ),
        backgroundColor: context.uiColors.red,
      ),
    );
  }
}

class _ScheduleAvatar extends StatelessWidget {
  final ScheduleEventTypeEnum type;
  final bool done;

  const _ScheduleAvatar({required this.type, required this.done});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 48,
      width: 48,
      duration: const Duration(milliseconds: _animationMiliseconds),
      decoration: BoxDecoration(
        color: done
            ? context.uiColors.black20
            : context.uiColors.lightOrange.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: _animationMiliseconds),
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: done
              ? Icon(
                  key: const ValueKey('done'),
                  type.icon,
                  size: 28,
                  color: context.uiColors.black60,
                )
              : Icon(
                  key: const ValueKey('not_done'),
                  type.icon,
                  size: 28,
                  color: context.uiColors.orangePrimary,
                ),
        ),
      ),
    );
  }
}
