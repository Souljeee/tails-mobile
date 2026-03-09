part of 'mark_done_bloc.dart';

typedef MarkDoneStateMatch<T, S extends MarkDoneState> = T Function(S state);

sealed class MarkDoneState extends Equatable {
  const MarkDoneState();

  const factory MarkDoneState.idle() = MarkDoneState$Idle;

  const factory MarkDoneState.loading() = MarkDoneState$Loading;

  const factory MarkDoneState.success() = MarkDoneState$Success;

  const factory MarkDoneState.error() = MarkDoneState$Error;

  T map<T>({
    required MarkDoneStateMatch<T, MarkDoneState$Idle> idle,
    required MarkDoneStateMatch<T, MarkDoneState$Loading> loading,
    required MarkDoneStateMatch<T, MarkDoneState$Success> success,
    required MarkDoneStateMatch<T, MarkDoneState$Error> error,
  }) =>
      switch (this) {
        final MarkDoneState$Idle state => idle(state),
        final MarkDoneState$Loading state => loading(state),
        final MarkDoneState$Success state => success(state),
        final MarkDoneState$Error state => error(state),
      };
      
  T? mapOrNull<T>({
    MarkDoneStateMatch<T, MarkDoneState$Idle>? idle,
    MarkDoneStateMatch<T, MarkDoneState$Loading>? loading,
    MarkDoneStateMatch<T, MarkDoneState$Success>? success,
    MarkDoneStateMatch<T, MarkDoneState$Error>? error,
  }) =>
      map<T?>(
        idle: idle ?? (_) => null,
        loading: loading ?? (_) => null,
        success: success ?? (_) => null,
        error: error ?? (_) => null,
      );
            
  T maybeMap<T>({
    required T Function() orElse,
    MarkDoneStateMatch<T, MarkDoneState$Idle>? idle,
    MarkDoneStateMatch<T, MarkDoneState$Loading>? loading,
    MarkDoneStateMatch<T, MarkDoneState$Success>? success,
    MarkDoneStateMatch<T, MarkDoneState$Error>? error,
  }) =>
      map<T>(
        idle: idle ?? (_) => orElse(),
        loading: loading ?? (_) => orElse(),
        success: success ?? (_) => orElse(),
        error: error ?? (_) => orElse(),
      );
}

/// States

final class MarkDoneState$Idle extends MarkDoneState {
  const MarkDoneState$Idle();

  @override
  List<Object?> get props => [];
}

final class MarkDoneState$Loading extends MarkDoneState {
  const MarkDoneState$Loading();

  @override
  List<Object?> get props => [];
}

final class MarkDoneState$Success extends MarkDoneState {
  const MarkDoneState$Success();

  @override
  List<Object?> get props => [];
}

final class MarkDoneState$Error extends MarkDoneState {
  const MarkDoneState$Error();

  @override
  List<Object?> get props => [];
}