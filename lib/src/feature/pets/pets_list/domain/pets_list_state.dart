part of 'pets_list_bloc.dart';

typedef PetsListStateMatch<T, S extends PetsListState> = T Function(S state);

sealed class PetsListState extends Equatable {
  const PetsListState();

  const factory PetsListState.loading() = PetsListState$Loading;

  const factory PetsListState.success({
    required List<PetModel> pets,
  }) = PetsListState$Success;

  const factory PetsListState.error() = PetsListState$Error;

  T map<T>({
    required PetsListStateMatch<T, PetsListState$Loading> loading,
    required PetsListStateMatch<T, PetsListState$Success> success,
    required PetsListStateMatch<T, PetsListState$Error> error,
  }) =>
      switch (this) {
        final PetsListState$Loading state => loading(state),
        final PetsListState$Success state => success(state),
        final PetsListState$Error state => error(state),
      };
      
  T? mapOrNull<T>({
    PetsListStateMatch<T, PetsListState$Loading>? loading,
    PetsListStateMatch<T, PetsListState$Success>? success,
    PetsListStateMatch<T, PetsListState$Error>? error,
  }) =>
      map<T?>(
        loading: loading ?? (_) => null,
        success: success ?? (_) => null,
        error: error ?? (_) => null,
      );
            
  T maybeMap<T>({
    required T Function() orElse,
    PetsListStateMatch<T, PetsListState$Loading>? loading,
    PetsListStateMatch<T, PetsListState$Success>? success,
    PetsListStateMatch<T, PetsListState$Error>? error,
  }) =>
      map<T>(
        loading: loading ?? (_) => orElse(),
        success: success ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class PetsListState$Loading extends PetsListState {
  const PetsListState$Loading();

  @override
  List<Object?> get props => [];
}

final class PetsListState$Success extends PetsListState {
  final List<PetModel> pets;

  const PetsListState$Success({
    required this.pets,
  });

  @override
  List<Object?> get props => [
        pets,
      ];
}

final class PetsListState$Error extends PetsListState {
  const PetsListState$Error();

  @override
  List<Object?> get props => [];
}