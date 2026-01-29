part of 'code_timer_bloc.dart';

typedef CodeTimerStateMatch<T, S extends CodeTimerState> = T Function(S state);

sealed class CodeTimerState extends Equatable {
  final int secondsRemaining;

  const CodeTimerState({required this.secondsRemaining});

  const factory CodeTimerState.idle({
    int secondsRemaining,
  }) = CodeTimerState$Idle;

  const factory CodeTimerState.ticking({
    required int secondsRemaining,
  }) = CodeTimerState$Ticking;

  T map<T>({
    required CodeTimerStateMatch<T, CodeTimerState$Idle> idle,
    required CodeTimerStateMatch<T, CodeTimerState$Ticking> ticking,
  }) =>
      switch (this) {
        final CodeTimerState$Idle state => idle(state),
        final CodeTimerState$Ticking state => ticking(state),
      };

  T? mapOrNull<T>({
    CodeTimerStateMatch<T, CodeTimerState$Idle>? idle,
    CodeTimerStateMatch<T, CodeTimerState$Ticking>? ticking,
  }) =>
      map<T?>(
        idle: idle ?? (_) => null,
        ticking: ticking ?? (_) => null,
      );

  T maybeMap<T>({
    required T Function() orElse,
    CodeTimerStateMatch<T, CodeTimerState$Idle>? idle,
    CodeTimerStateMatch<T, CodeTimerState$Ticking>? ticking,
  }) =>
      map<T>(
        idle: idle ?? (_) => orElse(),
        ticking: ticking ?? (_) => orElse(),
      );
}

/// States

final class CodeTimerState$Idle extends CodeTimerState {
  const CodeTimerState$Idle({super.secondsRemaining = 0});

  @override
  List<Object?> get props => [secondsRemaining];
}

final class CodeTimerState$Ticking extends CodeTimerState {
  const CodeTimerState$Ticking({required super.secondsRemaining});

  @override
  List<Object?> get props => [secondsRemaining];
}
