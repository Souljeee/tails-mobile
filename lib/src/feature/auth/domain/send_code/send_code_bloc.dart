import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/auth/data/repositories/auth_repository.dart';

part 'send_code_event.dart';
part 'send_code_state.dart';

class SendCodeBloc extends Bloc<SendCodeEvent, SendCodeState> {
  final AuthRepository _authRepository;
  Timer? _timer;
  static const _timerDuration = 60;

  SendCodeBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const SendCodeState.initial()) {
    on<SendCodeEvent>(
      (event, emit) => event.map(
        sendCodeRequested: (event) => _onSendCodeRequested(event, emit),
        timerTick: (event) => _onTimerTick(event, emit),
      ),
    );
  }

  Future<void> _onSendCodeRequested(
    SendCodeEvent$SendCodeRequested event,
    Emitter<SendCodeState> emit,
  ) async {
    try {
      emit(SendCodeState.loading(secondsRemaining: state.secondsRemaining));

      await _authRepository.sendCode(phoneNumber: event.phoneNumber);

      emit(const SendCodeState.success(secondsRemaining: _timerDuration));

      // Запускаем таймер после успешной отправки кода
      _startTimer();
    } catch (e, s) {
      addError(e, s);

      emit(SendCodeState.error(secondsRemaining: state.secondsRemaining));

      // Возвращаемся в начальное состояние с текущим таймером
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(SendCodeState.initial(secondsRemaining: state.secondsRemaining));
    }
  }

  Future<void> _onTimerTick(
    SendCodeEvent$TimerTick event,
    Emitter<SendCodeState> emit,
  ) async {
    final newSeconds = state.secondsRemaining - 1;

    if (newSeconds <= 0) {
      _timer?.cancel();
      emit(
        state.map(
          initial: (_) => const SendCodeState.initial(),
          loading: (_) => const SendCodeState.loading(),
          success: (_) => const SendCodeState.success(),
          error: (_) => const SendCodeState.error(),
        ),
      );
    } else {
      emit(
        state.map(
          initial: (_) => SendCodeState.initial(secondsRemaining: newSeconds),
          loading: (_) => SendCodeState.loading(secondsRemaining: newSeconds),
          success: (_) => SendCodeState.success(secondsRemaining: newSeconds),
          error: (_) => SendCodeState.error(secondsRemaining: newSeconds),
        ),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(const SendCodeEvent.timerTick());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
