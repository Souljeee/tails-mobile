import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/logging/tails_loggable.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pet_repository.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pets_repository_events.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';

part 'pet_details_event.dart';
part 'pet_details_state.dart';

class PetDetailsBloc extends Bloc<PetDetailsEvent, PetDetailsState> {
  final PetRepository _petRepository;
  final ScheduleRepository _scheduleRepository;
  final int _petId;

  late final StreamSubscription<PetsRepositoryEventsEvent> _petDetailsSubscription;

  PetDetailsBloc({
    required PetRepository petRepository,
    required ScheduleRepository scheduleRepository,
    required int petId,
  }) : _petRepository = petRepository,
       _scheduleRepository = scheduleRepository,
       _petId = petId,
       super(const PetDetailsState.loading()) {
    on<PetDetailsEvent>(
      (event, emit) => event.map(fetchRequested: (event) => _onFetchRequested(event, emit)),
    );

    _listenPetRepository();
  }

  void _listenPetRepository() {
    _petDetailsSubscription = _petRepository.eventStream.listen((event) {
      event.mapOrNull(petEdited: (event) => add(PetDetailsEvent.fetchRequested(id: _petId)));
    });
  }

  @override
  Future<void> close() {
    _petDetailsSubscription.cancel();
    return super.close();
  }

  Future<void> _onFetchRequested(
    PetDetailsEvent$FetchRequested event,
    Emitter<PetDetailsState> emit,
  ) async {
    final keepData = event.silent && state is PetDetailsState$Success;

    try {
      if (!keepData) {
        emit(const PetDetailsState.loading());
      }

      final petData = await _petRepository.getPetDetails(id: _petId);

      final upcomingEvents = await _loadUpcomingEvents();

      emit(PetDetailsState.success(petData: petData, upcomingEvents: upcomingEvents));
    } catch (e, s) {
      addError(e, s);

      // При тихом обновлении оставляем уже показанные данные.
      if (!keepData) {
        emit(const PetDetailsState.error());
      }
    } finally {
      event.completer?.complete();
    }
  }

  /// События не критичны для карточки: при ошибке показываем пустой список.
  Future<List<ScheduleEventModel>> _loadUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final events = await _scheduleRepository.getPetUpcomingEvents(
        petId: _petId,
        dateFrom: DateTime(now.year, now.month, now.day),
      );

      return events.values.expand((list) => list).toList();
    } catch (e, s) {
      addError(e, s);

      return const [];
    }
  }
}
