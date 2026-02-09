part of 'breeds_bloc.dart';

typedef BreedsStateMatch<T, S extends BreedsState> = T Function(S state);

sealed class BreedsState extends Equatable {
  const BreedsState();

  const factory BreedsState.loading() = BreedsState$Loading;

  const factory BreedsState.success({
    required List<BreedModel> breeds,
  }) = BreedsState$Success;

  const factory BreedsState.error() = BreedsState$Error;

  T map<T>({
    required BreedsStateMatch<T, BreedsState$Loading> loading,
    required BreedsStateMatch<T, BreedsState$Success> success,
    required BreedsStateMatch<T, BreedsState$Error> error,
  }) =>
      switch (this) {
        final BreedsState$Loading state => loading(state),
        final BreedsState$Success state => success(state),
        final BreedsState$Error state => error(state),
      };
      
  T? mapOrNull<T>({
    BreedsStateMatch<T, BreedsState$Loading>? loading,
    BreedsStateMatch<T, BreedsState$Success>? success,
    BreedsStateMatch<T, BreedsState$Error>? error,
  }) =>
      map<T?>(
        loading: loading ?? (_) => null,
        success: success ?? (_) => null,
        error: error ?? (_) => null,
      );
            
  T maybeMap<T>({
    required T Function() orElse,
    BreedsStateMatch<T, BreedsState$Loading>? loading,
    BreedsStateMatch<T, BreedsState$Success>? success,
    BreedsStateMatch<T, BreedsState$Error>? error,
  }) =>
      map<T>(
        loading: loading ?? (_) => orElse(),
        success: success ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class BreedsState$Loading extends BreedsState {
  const BreedsState$Loading();

  @override
  List<Object?> get props => [];
}

final class BreedsState$Success extends BreedsState {
  final List<BreedModel> breeds;

  const BreedsState$Success({
    required this.breeds,
  });

  @override
  List<Object?> get props => [
        breeds,
      ];
}

final class BreedsState$Error extends BreedsState {
  const BreedsState$Error();

  @override
  List<Object?> get props => [];
}