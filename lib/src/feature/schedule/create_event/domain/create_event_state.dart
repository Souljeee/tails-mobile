part of 'create_event_bloc.dart';

typedef CreateEventStateMatch<T, S extends CreateEventState> = T Function(S state);

sealed class CreateEventState extends Equatable {
  const CreateEventState();

  const factory CreateEventState.initial() = CreateEventState$Initial;

  const factory CreateEventState.loading() = CreateEventState$Loading;

  const factory CreateEventState.success() = CreateEventState$Success;

  const factory CreateEventState.error() = CreateEventState$Error;

  T map<T>({
    required CreateEventStateMatch<T, CreateEventState$Initial> initial,
    required CreateEventStateMatch<T, CreateEventState$Loading> loading,
    required CreateEventStateMatch<T, CreateEventState$Success> success,
    required CreateEventStateMatch<T, CreateEventState$Error> error,
  }) => switch (this) {
    final CreateEventState$Initial state => initial(state),
    final CreateEventState$Loading state => loading(state),
    final CreateEventState$Success state => success(state),
    final CreateEventState$Error state => error(state),
  };

  T? mapOrNull<T>({
    CreateEventStateMatch<T, CreateEventState$Initial>? initial,
    CreateEventStateMatch<T, CreateEventState$Loading>? loading,
    CreateEventStateMatch<T, CreateEventState$Success>? success,
    CreateEventStateMatch<T, CreateEventState$Error>? error,
  }) => map<T?>(
    initial: initial ?? (_) => null,
    loading: loading ?? (_) => null,
    success: success ?? (_) => null,
    error: error ?? (_) => null,
  );

  T maybeMap<T>({
    required T Function() orElse,
    CreateEventStateMatch<T, CreateEventState$Initial>? initial,
    CreateEventStateMatch<T, CreateEventState$Loading>? loading,
    CreateEventStateMatch<T, CreateEventState$Success>? success,
    CreateEventStateMatch<T, CreateEventState$Error>? error,
  }) => map<T>(
    initial: initial ?? (_) => orElse(),
    loading: loading ?? (_) => orElse(),
    success: success ?? (_) => orElse(),
    error: error ?? (_) => orElse(),
  );
}

/// States

final class CreateEventState$Initial extends CreateEventState {
  const CreateEventState$Initial();

  @override
  List<Object?> get props => [];
}

final class CreateEventState$Loading extends CreateEventState {
  const CreateEventState$Loading();

  @override
  List<Object?> get props => [];
}

final class CreateEventState$Success extends CreateEventState {
  const CreateEventState$Success();

  @override
  List<Object?> get props => [];
}

final class CreateEventState$Error extends CreateEventState {
  const CreateEventState$Error();

  @override
  List<Object?> get props => [];
}
