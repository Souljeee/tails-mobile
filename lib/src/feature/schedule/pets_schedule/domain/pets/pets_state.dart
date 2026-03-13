part of 'pets_bloc.dart';

typedef PetsStateMatch<T, S extends PetsState> = T Function(S state);

sealed class PetsState extends Equatable {
  const PetsState();

  const factory PetsState.loading() = PetsState$Loading;

  const factory PetsState.success({
    required List<PetModel> pets,
  }) = PetsState$Success;

  const factory PetsState.error() = PetsState$Error;

  T map<T>({
    required PetsStateMatch<T, PetsState$Loading> loading,
    required PetsStateMatch<T, PetsState$Success> success,
    required PetsStateMatch<T, PetsState$Error> error,
  }) =>
      switch (this) {
        final PetsState$Loading state => loading(state),
        final PetsState$Success state => success(state),
        final PetsState$Error state => error(state),
      };
      
  T? mapOrNull<T>({
    PetsStateMatch<T, PetsState$Loading>? loading,
    PetsStateMatch<T, PetsState$Success>? success,
    PetsStateMatch<T, PetsState$Error>? error,
  }) =>
      map<T?>(
        loading: loading ?? (_) => null,
        success: success ?? (_) => null,
        error: error ?? (_) => null,
      );
            
  T maybeMap<T>({
    required T Function() orElse,
    PetsStateMatch<T, PetsState$Loading>? loading,
    PetsStateMatch<T, PetsState$Success>? success,
    PetsStateMatch<T, PetsState$Error>? error,
  }) =>
      map<T>(
        loading: loading ?? (_) => orElse(),
        success: success ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class PetsState$Loading extends PetsState {
  const PetsState$Loading();

  @override
  List<Object?> get props => [];
}

final class PetsState$Success extends PetsState {
  final List<PetModel> pets;

  const PetsState$Success({
    required this.pets,
  });

  @override
  List<Object?> get props => [
        pets,
      ];
}

final class PetsState$Error extends PetsState {
  const PetsState$Error();

  @override
  List<Object?> get props => [];
}