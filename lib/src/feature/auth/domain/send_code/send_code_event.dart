part of 'send_code_bloc.dart';

typedef SendCodeEventMatch<T, S extends SendCodeEvent> = T Function(S event);

sealed class SendCodeEvent extends Equatable {
  const SendCodeEvent();

  const factory SendCodeEvent.sendCodeRequested({required String phoneNumber}) = SendCodeEvent$SendCodeRequested;

  T map<T>({
    required SendCodeEventMatch<T, SendCodeEvent$SendCodeRequested> sendCodeRequested,
  }) =>
      switch (this) {
        final SendCodeEvent$SendCodeRequested event => sendCodeRequested(event),
      };
}

final class SendCodeEvent$SendCodeRequested extends SendCodeEvent {
  const SendCodeEvent$SendCodeRequested({required this.phoneNumber});

  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}
