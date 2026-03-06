part of 'schedule_bloc.dart';

typedef ScheduleStateMatch<T, S extends ScheduleState> = T Function(S state);

sealed class ScheduleState extends Equatable {
  const ScheduleState();

  const factory ScheduleState.loading() = ScheduleState$Loading;

  const factory ScheduleState.success({
    required List<PetModel> pets,
    required ScheduleEventModelList scheduleEvents,
  }) = ScheduleState$Success;

  const factory ScheduleState.error() = ScheduleState$Error;

  T map<T>({
    required ScheduleStateMatch<T, ScheduleState$Loading> loading,
    required ScheduleStateMatch<T, ScheduleState$Success> success,
    required ScheduleStateMatch<T, ScheduleState$Error> error,
  }) =>
      switch (this) {
        final ScheduleState$Loading state => loading(state),
        final ScheduleState$Success state => success(state),
        final ScheduleState$Error state => error(state),
      };
      
  T? mapOrNull<T>({
    ScheduleStateMatch<T, ScheduleState$Loading>? loading,
    ScheduleStateMatch<T, ScheduleState$Success>? success,
    ScheduleStateMatch<T, ScheduleState$Error>? error,
  }) =>
      map<T?>(
        loading: loading ?? (_) => null,
        success: success ?? (_) => null,
        error: error ?? (_) => null,
      );
            
  T maybeMap<T>({
    required T Function() orElse,
    ScheduleStateMatch<T, ScheduleState$Loading>? loading,
    ScheduleStateMatch<T, ScheduleState$Success>? success,
    ScheduleStateMatch<T, ScheduleState$Error>? error,
  }) =>
      map<T>(
        loading: loading ?? (_) => orElse(),
        success: success ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class ScheduleState$Loading extends ScheduleState {
  const ScheduleState$Loading();

  @override
  List<Object?> get props => [];
}

final class ScheduleState$Success extends ScheduleState {
  final ScheduleEventModelList scheduleEvents;
  final List<PetModel> pets;
  final PaginationStatusEnum paginationStatus;

  const ScheduleState$Success({
    required this.scheduleEvents,
    required this.pets,
    this.paginationStatus = PaginationStatusEnum.idle,
  });

  ScheduleState$Success copyWith({
    CopyWithWrapper<ScheduleEventModelList>? scheduleEvents,
    CopyWithWrapper<List<PetModel>>? pets,
    CopyWithWrapper<PaginationStatusEnum>? paginationStatus,
  }) =>
      ScheduleState$Success(
        scheduleEvents: scheduleEvents?.value ?? this.scheduleEvents,
        pets: pets?.value ?? this.pets,
        paginationStatus: paginationStatus?.value ?? this.paginationStatus,
      );

  @override
  List<Object?> get props => [
        scheduleEvents,
        pets,
        paginationStatus,
      ];
}

final class ScheduleState$Error extends ScheduleState {
  const ScheduleState$Error();

  @override
  List<Object?> get props => [];
}