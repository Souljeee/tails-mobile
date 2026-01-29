part of 'code_timer_bloc.dart';

typedef CodeTimerEventMatch<T, S extends CodeTimerEvent> = T Function(S event);

sealed class CodeTimerEvent extends Equatable {
  const CodeTimerEvent();

  const factory CodeTimerEvent.started() = CodeTimerEvent$Started;

  const factory CodeTimerEvent.ticked() = CodeTimerEvent$Ticked;

  const factory CodeTimerEvent.reset() = CodeTimerEvent$Reset;

  T map<T>({
    required CodeTimerEventMatch<T, CodeTimerEvent$Started> started,
    required CodeTimerEventMatch<T, CodeTimerEvent$Ticked> ticked,
    required CodeTimerEventMatch<T, CodeTimerEvent$Reset> reset,
  }) =>
      switch (this) {
        final CodeTimerEvent$Started event => started(event),
        final CodeTimerEvent$Ticked event => ticked(event),
        final CodeTimerEvent$Reset event => reset(event),
      };

  T? mapOrNull<T>({
    CodeTimerEventMatch<T, CodeTimerEvent$Started>? started,
    CodeTimerEventMatch<T, CodeTimerEvent$Ticked>? ticked,
    CodeTimerEventMatch<T, CodeTimerEvent$Reset>? reset,
  }) =>
      map<T?>(
        started: started ?? (_) => null,
        ticked: ticked ?? (_) => null,
        reset: reset ?? (_) => null,
      );

  T maybeMap<T>({
    required T Function() orElse,
    CodeTimerEventMatch<T, CodeTimerEvent$Started>? started,
    CodeTimerEventMatch<T, CodeTimerEvent$Ticked>? ticked,
    CodeTimerEventMatch<T, CodeTimerEvent$Reset>? reset,
  }) =>
      map<T>(
        started: started ?? (_) => orElse(),
        ticked: ticked ?? (_) => orElse(),
        reset: reset ?? (_) => orElse(),
      );
}

final class CodeTimerEvent$Started extends CodeTimerEvent {
  const CodeTimerEvent$Started();

  @override
  List<Object?> get props => [];
}

final class CodeTimerEvent$Ticked extends CodeTimerEvent {
  const CodeTimerEvent$Ticked();

  @override
  List<Object?> get props => [];
}

final class CodeTimerEvent$Reset extends CodeTimerEvent {
  const CodeTimerEvent$Reset();

  @override
  List<Object?> get props => [];
}
