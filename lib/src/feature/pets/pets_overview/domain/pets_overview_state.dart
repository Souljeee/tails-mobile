part of 'pets_overview_bloc.dart';

typedef PetsOverviewStateMatch<T, S extends PetsOverviewState> = T Function(S state);

sealed class PetsOverviewState extends Equatable {
  const PetsOverviewState();

  const factory PetsOverviewState.loading() = PetsOverviewState$Loading;

  const factory PetsOverviewState.success({required PetsOverview overview}) =
      PetsOverviewState$Success;

  const factory PetsOverviewState.error() = PetsOverviewState$Error;

  T map<T>({
    required PetsOverviewStateMatch<T, PetsOverviewState$Loading> loading,
    required PetsOverviewStateMatch<T, PetsOverviewState$Success> success,
    required PetsOverviewStateMatch<T, PetsOverviewState$Error> error,
  }) => switch (this) {
    final PetsOverviewState$Loading state => loading(state),
    final PetsOverviewState$Success state => success(state),
    final PetsOverviewState$Error state => error(state),
  };

  T? mapOrNull<T>({
    PetsOverviewStateMatch<T, PetsOverviewState$Loading>? loading,
    PetsOverviewStateMatch<T, PetsOverviewState$Success>? success,
    PetsOverviewStateMatch<T, PetsOverviewState$Error>? error,
  }) => map<T?>(
    loading: loading ?? (_) => null,
    success: success ?? (_) => null,
    error: error ?? (_) => null,
  );

  T maybeMap<T>({
    required T Function() orElse,
    PetsOverviewStateMatch<T, PetsOverviewState$Loading>? loading,
    PetsOverviewStateMatch<T, PetsOverviewState$Success>? success,
    PetsOverviewStateMatch<T, PetsOverviewState$Error>? error,
  }) => map<T>(
    loading: loading ?? (_) => orElse(),
    success: success ?? (_) => orElse(),
    error: error ?? (_) => orElse(),
  );
}

/// States

final class PetsOverviewState$Loading extends PetsOverviewState {
  const PetsOverviewState$Loading();

  @override
  List<Object?> get props => [];
}

final class PetsOverviewState$Success extends PetsOverviewState {
  final PetsOverview overview;

  const PetsOverviewState$Success({required this.overview});

  @override
  List<Object?> get props => [overview];
}

final class PetsOverviewState$Error extends PetsOverviewState {
  const PetsOverviewState$Error();

  @override
  List<Object?> get props => [];
}
