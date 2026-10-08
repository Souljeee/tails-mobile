import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/core/analytics/analytics_reason_mapper.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/feature/auth/data/repositories/auth_repository.dart';
import 'package:tails_mobile/src/feature/auth/exceptions/code_sending_timer_exceptions.dart';

part 'send_code_event.dart';
part 'send_code_state.dart';

class SendCodeBloc extends Bloc<SendCodeEvent, SendCodeState> {
  final AuthRepository _authRepository;

  SendCodeBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const SendCodeState.initial()) {
    on<SendCodeEvent>(
      (event, emit) => event.map(sendCodeRequested: (event) => _onSendCodeRequested(event, emit)),
    );
  }

  Future<void> _onSendCodeRequested(
    SendCodeEvent$SendCodeRequested event,
    Emitter<SendCodeState> emit,
  ) async {
    try {
      emit(const SendCodeState.loading());

      await _authRepository.sendCode(phoneNumber: event.phoneNumber);

      TailsAnalytics.log(TailsAnalyticsEvents.loginCodeRequested(isResend: event.isResend));

      emit(const SendCodeState.success());

      // Возвращаемся в начальное состояние после небольшой задержки
      await Future<void>.delayed(const Duration(milliseconds: 100));
      emit(const SendCodeState.initial());
    } catch (e, s) {
      addError(e, s);
      TailsAnalytics.log(
        TailsAnalyticsEvents.loginCodeRequestFailed(
          e is CodeSendingTimerException ? AnalyticsReason.rateLimited : analyticsReasonOf(e),
        ),
      );

      emit(const SendCodeState.error());

      // Возвращаемся в начальное состояние
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(const SendCodeState.initial());
    }
  }
}
