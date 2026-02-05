part of 'add_pet_bloc.dart';

typedef AddPetStateMatch<T, S extends AddPetState> = T Function(S state);

sealed class AddPetState extends Equatable {
  const AddPetState();

  const factory AddPetState.initial() = AddPetState$Initial;

  const factory AddPetState.loading() = AddPetState$Loading;

  const factory AddPetState.success() = AddPetState$Success;

  const factory AddPetState.error() = AddPetState$Error;

  T map<T>({
    required AddPetStateMatch<T, AddPetState$Loading> loading,
    required AddPetStateMatch<T, AddPetState$Initial> initial,
    required AddPetStateMatch<T, AddPetState$Success> success,
    required AddPetStateMatch<T, AddPetState$Error> error,
  }) =>
      switch (this) {
        final AddPetState$Loading state => loading(state),
        final AddPetState$Initial state => initial(state),
        final AddPetState$Success state => success(state),
        final AddPetState$Error state => error(state),
      };
      
  T? mapOrNull<T>({
    AddPetStateMatch<T, AddPetState$Loading>? loading,
    AddPetStateMatch<T, AddPetState$Initial>? initial,
    AddPetStateMatch<T, AddPetState$Success>? success,
    AddPetStateMatch<T, AddPetState$Error>? error,
  }) =>
      map<T?>(
        loading: loading ?? (_) => null,
        initial: initial ?? (_) => null,
        success: success ?? (_) => null,
        error: error ?? (_) => null,
      );
            
  T maybeMap<T>({
    required T Function() orElse,
    AddPetStateMatch<T, AddPetState$Loading>? loading,
    AddPetStateMatch<T, AddPetState$Initial>? initial,
    AddPetStateMatch<T, AddPetState$Success>? success,
    AddPetStateMatch<T, AddPetState$Error>? error,
  }) =>
      map<T>(
        loading: loading ?? (_) => orElse(),
        initial: initial ?? (_) => orElse(),
        success: success ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class AddPetState$Initial extends AddPetState {
  const AddPetState$Initial();

  @override
  List<Object?> get props => [];
}

final class AddPetState$Loading extends AddPetState {
  const AddPetState$Loading();

  @override
  List<Object?> get props => [];
}

final class AddPetState$Success extends AddPetState {
  const AddPetState$Success();

  @override
  List<Object?> get props => [];
}

final class AddPetState$Error extends AddPetState {
  const AddPetState$Error();

  @override
  List<Object?> get props => [];
}
