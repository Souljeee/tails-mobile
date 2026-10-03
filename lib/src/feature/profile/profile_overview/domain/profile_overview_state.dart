part of 'profile_overview_bloc.dart';

typedef ProfileOverviewStateMatch<T, S extends ProfileOverviewState> = T Function(S state);

sealed class ProfileOverviewState extends Equatable {
  const ProfileOverviewState();

  const factory ProfileOverviewState.loading() = ProfileOverviewState$Loading;

  const factory ProfileOverviewState.error() = ProfileOverviewState$Error;

  const factory ProfileOverviewState.success({required ProfileOverview overview}) =
      ProfileOverviewState$Success;

  T map<T>({
    required ProfileOverviewStateMatch<T, ProfileOverviewState$Loading> loading,
    required ProfileOverviewStateMatch<T, ProfileOverviewState$Error> error,
    required ProfileOverviewStateMatch<T, ProfileOverviewState$Success> success,
  }) => switch (this) {
    final ProfileOverviewState$Loading state => loading(state),
    final ProfileOverviewState$Error state => error(state),
    final ProfileOverviewState$Success state => success(state),
  };

  T? mapOrNull<T>({
    ProfileOverviewStateMatch<T, ProfileOverviewState$Loading>? loading,
    ProfileOverviewStateMatch<T, ProfileOverviewState$Error>? error,
    ProfileOverviewStateMatch<T, ProfileOverviewState$Success>? success,
  }) => map<T?>(
    loading: loading ?? (_) => null,
    error: error ?? (_) => null,
    success: success ?? (_) => null,
  );
}

final class ProfileOverviewState$Loading extends ProfileOverviewState {
  const ProfileOverviewState$Loading();

  @override
  List<Object?> get props => [];
}

final class ProfileOverviewState$Error extends ProfileOverviewState {
  const ProfileOverviewState$Error();

  @override
  List<Object?> get props => [];
}

final class ProfileOverviewState$Success extends ProfileOverviewState {
  const ProfileOverviewState$Success({required this.overview});

  final ProfileOverview overview;

  @override
  List<Object?> get props => [overview];
}
