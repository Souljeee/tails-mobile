part of 'send_code_bloc.dart';

typedef SendCodeStateMatch<T, S extends SendCodeState> = T Function(S state);

sealed class SendCodeState extends Equatable {
  const SendCodeState();

  const factory SendCodeState.initial() = SendCodeState$Initial;

  const factory SendCodeState.loading() = SendCodeState$Loading;

  const factory SendCodeState.success() = SendCodeState$Success;

  const factory SendCodeState.error() = SendCodeState$Error;

  T map<T>({
    required SendCodeStateMatch<T, SendCodeState$Initial> initial,
    required SendCodeStateMatch<T, SendCodeState$Loading> loading,
    required SendCodeStateMatch<T, SendCodeState$Success> success,
    required SendCodeStateMatch<T, SendCodeState$Error> error,
  }) =>
      switch (this) {
        final SendCodeState$Initial state => initial(state),
        final SendCodeState$Loading state => loading(state),
        final SendCodeState$Success state => success(state),
        final SendCodeState$Error state => error(state),
      };

  T? mapOrNull<T>({
    SendCodeStateMatch<T, SendCodeState$Initial>? initial,
    SendCodeStateMatch<T, SendCodeState$Loading>? loading,
    SendCodeStateMatch<T, SendCodeState$Success>? success,
    SendCodeStateMatch<T, SendCodeState$Error>? error,
  }) =>
      map<T?>(
        initial: initial ?? (_) => null,
        loading: loading ?? (_) => null,
        success: success ?? (_) => null,
        error: error ?? (_) => null,
      );

  T maybeMap<T>({
    required T Function() orElse,
    SendCodeStateMatch<T, SendCodeState$Initial>? initial,
    SendCodeStateMatch<T, SendCodeState$Loading>? loading,
    SendCodeStateMatch<T, SendCodeState$Success>? success,
    SendCodeStateMatch<T, SendCodeState$Error>? error,
  }) =>
      map<T>(
        initial: initial ?? (_) => orElse(),
        loading: loading ?? (_) => orElse(),
        success: success ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class SendCodeState$Initial extends SendCodeState {
  const SendCodeState$Initial();

  @override
  List<Object?> get props => [];
}

final class SendCodeState$Loading extends SendCodeState {
  const SendCodeState$Loading();

  @override
  List<Object?> get props => [];
}

final class SendCodeState$Success extends SendCodeState {
  const SendCodeState$Success();

  @override
  List<Object?> get props => [];
}

final class SendCodeState$Error extends SendCodeState {
  const SendCodeState$Error();

  @override
  List<Object?> get props => [];
}
