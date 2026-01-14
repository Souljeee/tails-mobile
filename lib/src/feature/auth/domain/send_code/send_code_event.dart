part of 'send_code_bloc.dart';

typedef SendCodeEventMatch<T, S extends SendCodeEvent> = T Function(S event);

sealed class SendCodeEvent extends Equatable {
  const SendCodeEvent();

  const factory SendCodeEvent.sendCodeRequested({required String phoneNumber}) = SendCodeEvent$SendCodeRequested;

  const factory SendCodeEvent.timerTick() = SendCodeEvent$TimerTick;

  T map<T>({
    required SendCodeEventMatch<T, SendCodeEvent$SendCodeRequested> sendCodeRequested,
    required SendCodeEventMatch<T, SendCodeEvent$TimerTick> timerTick,
  }) =>
      switch (this) {
        final SendCodeEvent$SendCodeRequested event => sendCodeRequested(event),
        final SendCodeEvent$TimerTick event => timerTick(event),
      };

  T? mapOrNull<T>({
    SendCodeEventMatch<T, SendCodeEvent$SendCodeRequested>? sendCodeRequested,
    SendCodeEventMatch<T, SendCodeEvent$TimerTick>? timerTick,
  }) =>
      map<T?>(
        sendCodeRequested: sendCodeRequested ?? (_) => null,
        timerTick: timerTick ?? (_) => null,
      );

  T maybeMap<T>({
    required T Function() orElse,
    SendCodeEventMatch<T, SendCodeEvent$SendCodeRequested>? sendCodeRequested,
    SendCodeEventMatch<T, SendCodeEvent$TimerTick>? timerTick,
  }) =>
      map<T>(
        sendCodeRequested: sendCodeRequested ?? (_) => orElse(),
        timerTick: timerTick ?? (_) => orElse(),
      );
}

final class SendCodeEvent$SendCodeRequested extends SendCodeEvent {
  const SendCodeEvent$SendCodeRequested({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

final class SendCodeEvent$TimerTick extends SendCodeEvent {
  const SendCodeEvent$TimerTick();

  @override
  List<Object?> get props => [];
}
