import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pets_repository_events.dart';
import 'package:tails_mobile/src/feature/pets/pets_overview/domain/models/pets_overview.dart';
import 'package:tails_mobile/src/feature/pets/pets_overview/domain/next_event_selector.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';

part 'pets_overview_event.dart';
part 'pets_overview_state.dart';

class PetsOverviewBloc extends Bloc<PetsOverviewEvent, PetsOverviewState> {
  final PetRepository _petRepository;
  final ScheduleRepository _scheduleRepository;

  /// Сколько дней вперёд ищем ближайшее событие питомца.
  static const int _nextEventLookaheadDays = 30;

  late final StreamSubscription<PetsRepositoryEventsEvent> _petsRepositoryEventsSubscription;

  PetsOverviewBloc({
    required PetRepository petRepository,
    required ScheduleRepository scheduleRepository,
  }) : _petRepository = petRepository,
       _scheduleRepository = scheduleRepository,
       super(const PetsOverviewState.loading()) {
    on<PetsOverviewEvent>(
      (event, emit) => event.map(fetchRequested: (event) => _onFetchRequested(event, emit)),
    );

    _listenPetsRepository();
  }

  @override
  Future<void> close() {
    _petsRepositoryEventsSubscription.cancel();

    return super.close();
  }

  void _listenPetsRepository() {
    _petsRepositoryEventsSubscription = _petRepository.eventStream.listen((event) {
      event.mapOrNull(
        petsAdded: (event) => add(const PetsOverviewEvent.fetchRequested()),
        petEdited: (event) => add(const PetsOverviewEvent.fetchRequested()),
        petDeleted: (event) => add(const PetsOverviewEvent.fetchRequested()),
      );
    });
  }

  Future<void> _onFetchRequested(
    PetsOverviewEvent$FetchRequested event,
    Emitter<PetsOverviewState> emit,
  ) async {
    final hasData = state is PetsOverviewState$Success;

    try {
      if (!event.silent || !hasData) {
        emit(const PetsOverviewState.loading());
      }

      final pets = await _petRepository.getPets();
      final schedule = await _loadSchedule();

      emit(PetsOverviewState.success(overview: _buildOverview(pets, schedule)));
    } catch (e, s) {
      addError(e, s);

      // При тихом обновлении оставляем уже показанные данные.
      if (!event.silent || !hasData) {
        emit(const PetsOverviewState.error());
      }
    }
  }

  /// Ошибка расписания не должна ломать список питомцев, поэтому возвращаем `null`.
  Future<ScheduleEventModelList?> _loadSchedule() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      return await _scheduleRepository.getScheduleEvents(
        startDate: today,
        endDate: today.add(const Duration(days: _nextEventLookaheadDays)),
      );
    } catch (e, s) {
      addError(e, s);

      return null;
    }
  }

  PetsOverview _buildOverview(List<PetModel> pets, ScheduleEventModelList? schedule) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextEvents = schedule == null
        ? <int, PetNextEvent>{}
        : selectNextEvents(schedule, now: now);

    return PetsOverview(
      pets: [for (final pet in pets) PetOverview(pet: pet, nextEvent: nextEvents[pet.id])],
      todayEventsCount: schedule == null ? null : (schedule[today] ?? []).length,
    );
  }
}
