import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/navigation/shell_actions.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_errors/ui_fetching_error.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_button/ui_icon_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_popup/ui_popup.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_top_bar/ui_top_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/date_time_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/string_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/create_schedule_event_bottom_sheet.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/pets/pets_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/schedule/schedule_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/presentation/widgets/pets_chip_list.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/presentation/widgets/schedule_calendar.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/presentation/widgets/schedule_event_item.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with ShellActionMixin<ScheduleScreen> {
  @override
  ShellTab get shellTab => ShellTab.schedule;

  @override
  void onShellAction() => _openCreateEventBottomSheet();

  DateTime _selectedDate = DateTime.now().withoutTime;
  int? _selectedPetId;

  final _startDate = DateTime.now().subtract(const Duration(days: 180));
  final _endDate = DateTime.now().add(const Duration(days: 180));

  final MonthCalendarController _monthController = MonthCalendarController(DateTime.now());

  late final PetsBloc _petsBloc = PetsBloc(
    petRepository: DependenciesScope.of(context).petRepository,
  );
  late final ScheduleBloc _scheduleBloc = ScheduleBloc(
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
  );

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    _petsBloc.close();
    _scheduleBloc.close();
    _monthController.dispose();

    super.dispose();
  }

  void _loadData() {
    _petsBloc.add(const PetsEvent.petsRequested());
    _reloadSchedule();
  }

  void _reloadSchedule() {
    _scheduleBloc.add(
      ScheduleEvent.fetchRequested(startDate: _startDate, endDate: _endDate, petId: _selectedPetId),
    );
  }

  Future<void> _openCreateEventBottomSheet() async {
    final result = await showUiPopup<CreateScheduleEventResult>(
      context: context,
      child: CreateScheduleEventBottomSheet(
        date: _selectedDate,
        pets: _petsBloc.state.mapOrNull<List<PetModel>?>(success: (state) => state.pets) ?? [],
        selectedPetId: _selectedPetId,
      ),
    );

    if (!mounted) {
      return;
    }

    switch (result) {
      case CreateScheduleEventResult.success:
        _reloadSchedule();
      case CreateScheduleEventResult.error:
        _showCreateEventErrorSnackBar();
      case null:
        break;
    }
  }

  void _showCreateEventErrorSnackBar() {
    showUiSnackBar(context, message: context.l10n.tryLater);
  }

  void _goToToday() {
    final today = DateTime.now().withoutTime;

    setState(() {
      _selectedDate = today;
    });

    _monthController.goToMonth(today);
  }

  List<PetModel> get _pets =>
      _petsBloc.state.mapOrNull<List<PetModel>?>(success: (state) => state.pets) ?? [];

  Color _petColor(int petId) {
    final index = _pets.indexWhere((pet) => pet.id == petId);
    return context.uiPalette.petColor(index < 0 ? 0 : index);
  }

  void _onPetChanged(int? petId) {
    setState(() {
      _selectedPetId = petId;
    });

    _reloadSchedule();
  }

  void _onEventToggle(ScheduleEventModel event, {required bool value}) {
    _scheduleBloc.add(
      ScheduleEvent.markDoneRequested(eventId: event.id, date: _selectedDate, value: value),
    );
  }

  String? _todayCountLabel(ScheduleState state) {
    final count = state.mapOrNull<int>(
      success: (state) => (state.scheduleEvents[DateTime.now().withoutTime] ?? []).length,
    );

    return count == null ? null : context.l10n.scheduleTodayCount(count);
  }

  List<Color> _markersFor(ScheduleState state, DateTime date) {
    final events = state.mapOrNull<List<ScheduleEventModel>>(
      success: (state) => state.scheduleEvents[date.withoutTime] ?? [],
    );

    if (events == null) {
      return const [];
    }

    return events.map((event) => event.petId).toSet().map(_petColor).toList();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Scaffold(
      backgroundColor: palette.canvas,
      body: BlocBuilder<PetsBloc, PetsState>(
        bloc: _petsBloc,
        builder: (context, petsState) {
          return BlocBuilder<ScheduleBloc, ScheduleState>(
            bloc: _scheduleBloc,
            builder: (context, scheduleState) {
              return SafeArea(
                bottom: false,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: UiLargeTitleHeader(
                        title: context.l10n.navCalendar,
                        subtitle: _todayCountLabel(scheduleState),
                        trailing: _TodayButton(onPressed: _goToToday),
                      ),
                    ),
                    SliverToBoxAdapter(child: _MonthHeader(controller: _monthController)),
                    SliverToBoxAdapter(
                      child: _PetChipsSection(state: petsState, onChanged: _onPetChanged),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: UiSpacing.x4)),
                    SliverToBoxAdapter(
                      child: ScheduleCalendar(
                        selectedDate: _selectedDate,
                        controller: _monthController,
                        onDateTap: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                        resolveMarkers: (date) => _markersFor(scheduleState, date),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: UiSpacing.x5)),
                    _EventsSliver(
                      state: scheduleState,
                      date: _selectedDate,
                      pets: _pets,
                      petColorOf: _petColor,
                      onToggle: _onEventToggle,
                      onRetry: _reloadSchedule,
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(bottom: ShellScope.bottomInsetOf(context)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _TodayButton extends StatelessWidget {
  const _TodayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Semantics(
      button: true,
      child: Material(
        color: palette.surface,
        shape: StadiumBorder(side: BorderSide(color: palette.line)),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          splashFactory: NoSplash.splashFactory,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: UiSizes.minTapTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4),
              child: Center(
                widthFactor: 1,
                child: Text(
                  context.l10n.scheduleToday,
                  style: context.uiFonts.callout.copyWith(
                    color: palette.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.controller});

  final MonthCalendarController controller;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpacing.x5, UiSpacing.x2, UiSpacing.x5, UiSpacing.x2),
      child: ValueListenableBuilder<DateTime>(
        valueListenable: controller,
        builder: (context, month, child) {
          final title = DateFormat.yMMMM(locale).format(month).replaceAll(' г.', '');

          return Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    title.toFirstLetterUpperCase(),
                    style: context.uiFonts.headline.copyWith(color: context.uiPalette.ink),
                  ),
                ),
              ),
              UiIconButton(
                icon: Icons.chevron_left,
                semanticLabel: context.l10n.schedulePreviousMonth,
                onPressed: controller.previousMonth,
              ),
              const SizedBox(width: UiSpacing.x2),
              UiIconButton(
                icon: Icons.chevron_right,
                semanticLabel: context.l10n.scheduleNextMonth,
                onPressed: controller.nextMonth,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PetChipsSection extends StatelessWidget {
  const _PetChipsSection({required this.state, required this.onChanged});

  final PetsState state;
  final OnSelectedPetsChanged onChanged;

  @override
  Widget build(BuildContext context) {
    return state.map(
      loading: (_) => const _PetsShimmer(),
      success: (state) => PetsChipList(pets: state.pets, onSelectedPetsChanged: onChanged),
      error: (_) => const SizedBox.shrink(),
    );
  }
}

class _EventsSliver extends StatelessWidget {
  const _EventsSliver({
    required this.state,
    required this.date,
    required this.pets,
    required this.petColorOf,
    required this.onToggle,
    required this.onRetry,
  });

  final ScheduleState state;
  final DateTime date;
  final List<PetModel> pets;
  final Color Function(int petId) petColorOf;
  final void Function(ScheduleEventModel event, {required bool value}) onToggle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return state.map(
      loading: (_) => const SliverToBoxAdapter(child: _EventsShimmer()),
      error: (_) => SliverToBoxAdapter(child: UiFetchingError(onRetry: onRetry)),
      success: (state) {
        final events = state.scheduleEvents[date] ?? [];
        final locale = Localizations.localeOf(context).toString();
        final dayTitle = DateFormat('EEEE, d MMMM', locale).format(date).toUpperCase();

        return SliverMainAxisGroup(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(UiSpacing.x5, 0, UiSpacing.x5, UiSpacing.x3),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          dayTitle,
                          style: fonts.monoEyebrow.copyWith(color: palette.ink2),
                        ),
                      ),
                    ),
                    Text(
                      l10n.scheduleEventsCount(events.length),
                      style: fonts.monoMeta.copyWith(color: palette.ink3),
                    ),
                  ],
                ),
              ),
            ),
            if (events.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiSpacing.x5,
                    vertical: UiSpacing.x6,
                  ),
                  child: Text(
                    l10n.scheduleEmptyDay,
                    textAlign: TextAlign.center,
                    style: fonts.body.copyWith(color: palette.ink3),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
                sliver: SliverList.separated(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];

                    return ScheduleEventItem(
                      key: ValueKey(event.id),
                      event: event,
                      pet: pets.firstWhereOrNull((pet) => pet.id == event.petId),
                      petColor: petColorOf(event.petId),
                      onToggle: (value) => onToggle(event, value: value),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: UiSpacing.x2),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EventsShimmer extends StatelessWidget {
  const _EventsShimmer();

  @override
  Widget build(BuildContext context) {
    return UiKitShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
        child: Column(
          children: List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: UiSpacing.x2),
              child: UiKitShimmerLoading(height: 72, borderRadius: UiRadius.mdAll),
            ),
          ),
        ),
      ),
    );
  }
}

class _PetsShimmer extends StatelessWidget {
  const _PetsShimmer();

  @override
  Widget build(BuildContext context) {
    return UiKitShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
        child: Row(
          spacing: UiSpacing.x2,
          children: List.generate(
            3,
            (index) => const UiKitShimmerLoading(
              height: UiChip.height,
              width: 100,
              borderRadius: UiRadius.fullAll,
            ),
          ),
        ),
      ),
    );
  }
}
