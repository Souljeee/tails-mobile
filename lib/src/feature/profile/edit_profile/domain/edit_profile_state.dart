part of 'edit_profile_bloc.dart';

typedef EditProfileStateMatch<T, S extends EditProfileState> = T Function(S state);

sealed class EditProfileState extends Equatable {
  const EditProfileState();

  const factory EditProfileState.initial() = EditProfileState$Initial;

  const factory EditProfileState.loading() = EditProfileState$Loading;

  const factory EditProfileState.success() = EditProfileState$Success;

  /// [isValidation] — сервер отклонил имя или фото.
  const factory EditProfileState.error({bool isValidation}) = EditProfileState$Error;

  T map<T>({
    required EditProfileStateMatch<T, EditProfileState$Initial> initial,
    required EditProfileStateMatch<T, EditProfileState$Loading> loading,
    required EditProfileStateMatch<T, EditProfileState$Success> success,
    required EditProfileStateMatch<T, EditProfileState$Error> error,
  }) => switch (this) {
    final EditProfileState$Initial state => initial(state),
    final EditProfileState$Loading state => loading(state),
    final EditProfileState$Success state => success(state),
    final EditProfileState$Error state => error(state),
  };

  T? mapOrNull<T>({
    EditProfileStateMatch<T, EditProfileState$Initial>? initial,
    EditProfileStateMatch<T, EditProfileState$Loading>? loading,
    EditProfileStateMatch<T, EditProfileState$Success>? success,
    EditProfileStateMatch<T, EditProfileState$Error>? error,
  }) => map<T?>(
    initial: initial ?? (_) => null,
    loading: loading ?? (_) => null,
    success: success ?? (_) => null,
    error: error ?? (_) => null,
  );
}

final class EditProfileState$Initial extends EditProfileState {
  const EditProfileState$Initial();

  @override
  List<Object?> get props => [];
}

final class EditProfileState$Loading extends EditProfileState {
  const EditProfileState$Loading();

  @override
  List<Object?> get props => [];
}

final class EditProfileState$Success extends EditProfileState {
  const EditProfileState$Success();

  @override
  List<Object?> get props => [];
}

final class EditProfileState$Error extends EditProfileState {
  const EditProfileState$Error({this.isValidation = false});

  final bool isValidation;

  @override
  List<Object?> get props => [isValidation];
}
