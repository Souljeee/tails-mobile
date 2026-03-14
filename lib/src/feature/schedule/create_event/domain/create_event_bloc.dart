import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';

part 'create_event_event.dart';
part 'create_event_state.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final ScheduleRepository _scheduleRepository;

  CreateEventBloc({required ScheduleRepository scheduleRepository})
    : _scheduleRepository = scheduleRepository,
      super(const CreateEventState.initial()) {
    on<CreateEventEvent>(
      (event, emit) => event.map(
        createRequested: (event) => _onCreateRequested(event, emit),
      ),
    );
  }

  Future<void> _onCreateRequested(
    CreateEventEvent$CreateRequested event,
    Emitter<CreateEventState> emit,
  ) async {
    try {
      emit(const CreateEventState.loading());

      await _scheduleRepository.createEvent(model: event.model);

      emit(const CreateEventState.success());
    } catch (e, s) {
      addError(e, s);

      emit(const CreateEventState.error());
    }finally {
      emit(const CreateEventState.initial());
    }
  }
}