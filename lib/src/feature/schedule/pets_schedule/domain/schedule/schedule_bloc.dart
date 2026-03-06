import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/constant/enums/pagination_status_enum.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/schedule_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/schedule_repository.dart';

part 'schedule_event.dart';
part 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final ScheduleRepository _scheduleRepository;

  ScheduleBloc({
    required ScheduleRepository scheduleRepository,
  }) : _scheduleRepository = scheduleRepository,
       super(const ScheduleState.loading()) {
    on<ScheduleEvent>(
      (event, emit) => event.map(fetchRequested: (event) => _onFetchRequested(event, emit), loadMoreRequested: (event) => _onLoadMoreRequested(event, emit)),
    );
  }

  Future<void> _onFetchRequested(
    ScheduleEvent$FetchRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    try {
      emit(const ScheduleState.loading());

      final ScheduleEventModelList scheduleEvents = await _scheduleRepository.getScheduleEvents(
          startDate: event.startDate,
          endDate: event.endDate,
          petId: event.petId,
        );

      emit(ScheduleState.success(scheduleEvents: scheduleEvents));
    } catch (e, s) {
      addError(e, s);

      emit(const ScheduleState.error());
    }
  }

  Future<void> _onLoadMoreRequested(
    ScheduleEvent$LoadMoreRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    await state.mapOrNull(
      success: (state) async {
        try {
          emit(
            state.copyWith(
              paginationStatus: const CopyWithWrapper.value(PaginationStatusEnum.loading),
            ),
          );

          final scheduleEvents = await _scheduleRepository.getScheduleEvents(
            startDate: event.startDate,
            endDate: event.endDate,
            petId: event.petId,
          );

          emit(
            state.copyWith(
              scheduleEvents: CopyWithWrapper.value(scheduleEvents),
              paginationStatus: const CopyWithWrapper.value(PaginationStatusEnum.idle),
            ),
          );
        } catch (e, s) {
          addError(e, s);

          emit(
            state.copyWith(
              paginationStatus: const CopyWithWrapper.value(PaginationStatusEnum.error),
            ),
          );
        }
      },
    );
  }
}
