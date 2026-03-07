import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_app_bar/ui_app_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
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

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime selectedDate = DateTime.now();

  String get formattedSelectedDate => DateFormat.MMMMd().format(selectedDate);

  late final PetsBloc _petsBloc = PetsBloc(
    petRepository: DependenciesScope.of(context).petRepository,
  );
  late final ScheduleBloc _scheduleBloc = ScheduleBloc(
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
  );

  late List<ScheduleEventModel> _events = List.of(_mockedScheduleEvents);

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  @override
  void dispose() {
    _petsBloc.close();
    _scheduleBloc.close();

    super.dispose();
  }

  void _loadData() {
    _petsBloc.add(const PetsEvent.petsRequested());
    _scheduleBloc.add(ScheduleEvent.fetchRequested(startDate: selectedDate, endDate: selectedDate));
  }

  void _toggleEvent(int index) {
    setState(() {
      final event = _events[index];
      _events[index] = ScheduleEventModel(
        id: event.id,
        petId: event.petId,
        title: event.title,
        type: event.type,
        done: !event.done,
        date: event.date,
        description: event.description,
        time: event.time,
        timeZoneOffset: event.timeZoneOffset,
        recurrence: event.recurrence,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.uiColors.grayMain,
      appBar: const UiAppBar.baseToolBar(title: 'Календарь'),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add event
        },
        backgroundColor: context.uiColors.orangePrimary,
        child: Icon(Icons.add, color: context.uiColors.white),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<PetsBloc, PetsState>(
                    bloc: _petsBloc,
                    builder: (context, state) {
                      return state.map(
                        loading: (_) => const _PetsShimmer(),
                        success: (state) => PetsChipList(
                          pets: state.pets,
                          onSelectedPetsChanged: (selectedPetIds) {},
                        ),
                        error: (_) => const SizedBox.shrink(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ScheduleCalendar(
                    selectedDate: selectedDate,
                    onDateTap: (date) {
                      setState(() {
                        selectedDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(formattedSelectedDate, style: context.uiFonts.header24Semibold),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: _events.length,
                itemBuilder: (context, index) {
                  return ScheduleEventItem(
                    event: _events[index],
                    pet: _petsBloc.state.mapOrNull<PetModel?>(
                      success: (state) => state.pets.firstWhereOrNull(
                        (pet) => pet.id == _events[index].petId,
                      ),
                    ),
                    onToggle: () => _toggleEvent(index),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
              ),
            ),
          ],
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
        physics: const BouncingScrollPhysics(),
        child: Row(
          spacing: 12,
          children: List.generate(
            3,
            (index) => UiKitShimmerLoading(
              height: 50,
              width: 100,
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
      ),
    );
  }
}

final _mockedScheduleEvents = [
  ScheduleEventModel(
    id: '1',
    petId: 1,
    title: 'Event 1',
    type: ScheduleEventTypeEnum.deworming,
    done: false,
    date: DateTime.now(),
    time: '12:00',
  ),
  ScheduleEventModel(
    id: '2',
    petId: 2,
    title: 'Event 2',
    type: ScheduleEventTypeEnum.yearlyVaccination,
    done: false,
    date: DateTime.now(),
  ),
  ScheduleEventModel(
    id: '3',
    petId: 3,
    title: 'Event 3',
    type: ScheduleEventTypeEnum.rabiesVaccination,
    done: false,
    date: DateTime.now(),
  ),
  ScheduleEventModel(
    id: '4',
    petId: 4,
    title: 'Event 4',
    type: ScheduleEventTypeEnum.weeklyPills,
    done: false,
    date: DateTime.now(),
    time: '13:00',
  ),
  ScheduleEventModel(
    id: '5',
    petId: 5,
    title: 'Event 5',
    type: ScheduleEventTypeEnum.dailyPills,
    done: false,
    date: DateTime.now(),
  ),
];
