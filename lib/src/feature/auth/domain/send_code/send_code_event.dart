part of 'send_code_bloc.dart';

typedef SendCodeEventMatch<T, S extends SendCodeEvent> = T Function(S event);

sealed class SendCodeEvent extends Equatable {
  const SendCodeEvent();

  const factory SendCodeEvent.sendCodeRequested({required String phoneNumber, bool isResend}) =
      SendCodeEvent$SendCodeRequested;

  T map<T>({required SendCodeEventMatch<T, SendCodeEvent$SendCodeRequested> sendCodeRequested}) =>
      switch (this) {
        final SendCodeEvent$SendCodeRequested event => sendCodeRequested(event),
      };

  T? mapOrNull<T>({SendCodeEventMatch<T, SendCodeEvent$SendCodeRequested>? sendCodeRequested}) =>
      map<T?>(sendCodeRequested: sendCodeRequested ?? (_) => null);

  T maybeMap<T>({
    required T Function() orElse,
    SendCodeEventMatch<T, SendCodeEvent$SendCodeRequested>? sendCodeRequested,
  }) => map<T>(sendCodeRequested: sendCodeRequested ?? (_) => orElse());
}

final class SendCodeEvent$SendCodeRequested extends SendCodeEvent {
  const SendCodeEvent$SendCodeRequested({required this.phoneNumber, this.isResend = false});

  final String phoneNumber;

  /// Повторная отправка кода (ссылка «Позвонить снова»).
  final bool isResend;

  @override
  List<Object?> get props => [phoneNumber, isResend];
}
