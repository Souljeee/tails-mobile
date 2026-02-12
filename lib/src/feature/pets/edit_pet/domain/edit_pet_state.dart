part of 'edit_pet_bloc.dart';

typedef EditPetStateMatch<T, S extends EditPetState> = T Function(S state);

sealed class EditPetState extends Equatable {
  const EditPetState();

  const factory EditPetState.initial() = EditPetState$Initial;

  const factory EditPetState.loading() = EditPetState$Loading;

  const factory EditPetState.success() = EditPetState$Success;

  const factory EditPetState.error() = EditPetState$Error;

  T map<T>({
    required EditPetStateMatch<T, EditPetState$Initial> initial,
        required EditPetStateMatch<T, EditPetState$Loading> loading,
    required EditPetStateMatch<T, EditPetState$Success> success,
    required EditPetStateMatch<T, EditPetState$Error> error,
  }) =>
      switch (this) {
        final EditPetState$Initial state => initial(state),
        final EditPetState$Loading state => loading(state),
        final EditPetState$Success state => success(state),
        final EditPetState$Error state => error(state),
      };
      
  T? mapOrNull<T>({
    EditPetStateMatch<T, EditPetState$Initial>? initial,
    EditPetStateMatch<T, EditPetState$Loading>? loading,
    EditPetStateMatch<T, EditPetState$Success>? success,
    EditPetStateMatch<T, EditPetState$Error>? error,
  }) =>
      map<T?>(
        initial: initial ?? (_) => null,
        loading: loading ?? (_) => null,
        success: success ?? (_) => null,
        error: error ?? (_) => null,
      );
            
  T maybeMap<T>({
    required T Function() orElse,
    EditPetStateMatch<T, EditPetState$Initial>? initial,
    EditPetStateMatch<T, EditPetState$Loading>? loading,
    EditPetStateMatch<T, EditPetState$Success>? success,
    EditPetStateMatch<T, EditPetState$Error>? error,
  }) =>
      map<T>(
        initial: initial ?? (_) => orElse(),
        loading: loading ?? (_) => orElse(),
        success: success ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class EditPetState$Initial extends EditPetState {
  const EditPetState$Initial();

  @override
  List<Object?> get props => [];
}

final class EditPetState$Loading extends EditPetState {
  const EditPetState$Loading();

  @override
  List<Object?> get props => [];
}

final class EditPetState$Success extends EditPetState {


  const EditPetState$Success();

  @override
  List<Object?> get props => [];
}

final class EditPetState$Error extends EditPetState {
  const EditPetState$Error();

  @override
  List<Object?> get props => [];
}