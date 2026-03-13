import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_app_bar/ui_app_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_shimmer/ui_shimmer.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/date_time_extension.dart';
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
  DateTime _selectedDate = DateTime.now().withoutTime;

  final _startDate = DateTime.now().subtract(const Duration(days: 180));
  final _endDate = DateTime.now().add(const Duration(days: 180));

  String get _formattedSelectedDate => DateFormat.MMMMd().format(_selectedDate);

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

    super.dispose();
  }

  void _loadData() {
    _petsBloc.add(const PetsEvent.petsRequested());
    _scheduleBloc.add(ScheduleEvent.fetchRequested(startDate: _startDate, endDate: _endDate));
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
                          onSelectedPetsChanged: (selectedPetId) {
                            _scheduleBloc.add(
                              ScheduleEvent.fetchRequested(
                                startDate: _startDate,
                                endDate: _endDate,
                                petId: selectedPetId,
                              ),
                            );
                          },
                        ),
                        error: (_) => const SizedBox.shrink(),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  ScheduleCalendar(
                    selectedDate: _selectedDate,
                    onDateTap: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(_formattedSelectedDate, style: context.uiFonts.header24Semibold),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            BlocBuilder<ScheduleBloc, ScheduleState>(
              bloc: _scheduleBloc,
              builder: (context, state) {
                return state.map(
                  error: (_) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  loading: (_) => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  success: (state) {
                    final events = state.scheduleEvents[_selectedDate] ?? [];

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.separated(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return ScheduleEventItem(
                            event: events[index],
                            pet: _petsBloc.state.mapOrNull<PetModel?>(
                              success: (state) => state.pets.firstWhereOrNull(
                                (pet) => pet.id == events[index].petId,
                              ),
                            ),
                            onToggle: (value) {
                              _scheduleBloc.add(
                                ScheduleEvent.markDoneRequested(
                                  eventId: events[index].id,
                                  date: _selectedDate,
                                  value: value,
                                ),  
                              );
                            },
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                      ),
                    );
                  },
                );
              },
            ),
            const SliverPadding(
              padding: EdgeInsets.only(
                bottom: 72 + 16,
              ), // FAB height (56) + FAB margin (16) + extra gap (16)
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
