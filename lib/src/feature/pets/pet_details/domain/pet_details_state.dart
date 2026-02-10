part of 'pet_details_bloc.dart';

typedef PetDetailsStateMatch<T, S extends PetDetailsState> = T Function(S state);

sealed class PetDetailsState extends Equatable {
  const PetDetailsState();

  const factory PetDetailsState.loading() = PetDetailsState$Loading;

  const factory PetDetailsState.success({
    required PetDetailsModel petData,
  }) = PetDetailsState$Success;

  const factory PetDetailsState.error() = PetDetailsState$Error;

  T map<T>({
    required PetDetailsStateMatch<T, PetDetailsState$Loading> loading,
    required PetDetailsStateMatch<T, PetDetailsState$Success> success,
    required PetDetailsStateMatch<T, PetDetailsState$Error> error,
  }) =>
      switch (this) {
        final PetDetailsState$Loading state => loading(state),
        final PetDetailsState$Success state => success(state),
        final PetDetailsState$Error state => error(state),
      };
      
  T? mapOrNull<T>({
    PetDetailsStateMatch<T, PetDetailsState$Loading>? loading,
    PetDetailsStateMatch<T, PetDetailsState$Success>? success,
    PetDetailsStateMatch<T, PetDetailsState$Error>? error,
  }) =>
      map<T?>(
        loading: loading ?? (_) => null,
        success: success ?? (_) => null,
        error: error ?? (_) => null,
      );
            
  T maybeMap<T>({
    required T Function() orElse,
    PetDetailsStateMatch<T, PetDetailsState$Loading>? loading,
    PetDetailsStateMatch<T, PetDetailsState$Success>? success,
    PetDetailsStateMatch<T, PetDetailsState$Error>? error,
  }) =>
      map<T>(
        loading: loading ?? (_) => orElse(),
        success: success ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class PetDetailsState$Loading extends PetDetailsState {
  const PetDetailsState$Loading();

  @override
  List<Object?> get props => [];
}

final class PetDetailsState$Success extends PetDetailsState {
  final PetDetailsModel petData;

  const PetDetailsState$Success({
    required this.petData,
  });

  @override
  List<Object?> get props => [
        petData,
      ];
}

final class PetDetailsState$Error extends PetDetailsState {
  const PetDetailsState$Error();

  @override
  List<Object?> get props => [];
}