part of 'delete_pet_bloc.dart';

typedef DeletePetStateMatch<T, S extends DeletePetState> = T Function(S state);

sealed class DeletePetState extends Equatable {
  const DeletePetState();

  const factory DeletePetState.initial() = DeletePetState$Initial;

  const factory DeletePetState.loading() = DeletePetState$Loading;

    const factory DeletePetState.success() = DeletePetState$Success;

  const factory DeletePetState.error() = DeletePetState$Error;

  T map<T>({
    required DeletePetStateMatch<T, DeletePetState$Initial> initial,
    required DeletePetStateMatch<T, DeletePetState$Loading> loading,
    required DeletePetStateMatch<T, DeletePetState$Success> success,
    required DeletePetStateMatch<T, DeletePetState$Error> error,
  }) =>
      switch (this) {
        final DeletePetState$Initial state => initial(state),
        final DeletePetState$Loading state => loading(state),
        final DeletePetState$Success state => success(state),
        final DeletePetState$Error state => error(state),
      };

  T? mapOrNull<T>({
    DeletePetStateMatch<T, DeletePetState$Initial>? initial,
    DeletePetStateMatch<T, DeletePetState$Loading>? loading,
    DeletePetStateMatch<T, DeletePetState$Success>? success,
    DeletePetStateMatch<T, DeletePetState$Error>? error,
  }) =>
      map<T?>(
        initial: initial ?? (_) => null,
        loading: loading ?? (_) => null,
        success: success ?? (_) => null,
        error: error ?? (_) => null,
      );

  T maybeMap<T>({
    required T Function() orElse,
    DeletePetStateMatch<T, DeletePetState$Initial>? initial,
    DeletePetStateMatch<T, DeletePetState$Loading>? loading,
    DeletePetStateMatch<T, DeletePetState$Success>? success,
    DeletePetStateMatch<T, DeletePetState$Error>? error,
  }) =>
      map<T>(
        initial: initial ?? (_) => orElse(),
        loading: loading ?? (_) => orElse(),
        success: success ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class DeletePetState$Initial extends DeletePetState {
  const DeletePetState$Initial();

  @override
  List<Object?> get props => [];
}

final class DeletePetState$Loading extends DeletePetState {
  const DeletePetState$Loading();

  @override
  List<Object?> get props => [];
}

final class DeletePetState$Success extends DeletePetState {
  const DeletePetState$Success();

  @override
  List<Object?> get props => [];
}

final class DeletePetState$Error extends DeletePetState {
  const DeletePetState$Error();

  @override
  List<Object?> get props => [];
}
