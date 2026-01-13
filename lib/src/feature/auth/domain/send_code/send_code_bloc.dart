import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/auth/data/repositories/auth_repository.dart';

part 'send_code_event.dart';
part 'send_code_state.dart';

class SendCodeBloc extends Bloc<SendCodeEvent, SendCodeState> {
  final AuthRepository _authRepository;

  SendCodeBloc({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const SendCodeState.initial()) {
    on<SendCodeEvent>(
      (event, emit) => event.map(
        sendCodeRequested: (event) => _onSendCodeRequested(event, emit),
      ),
    );
  }

  Future<void> _onSendCodeRequested(
    SendCodeEvent$SendCodeRequested event,
    Emitter<SendCodeState> emit,
  ) async {
    try {
      emit(const SendCodeState.loading());

      await _authRepository.sendCode(phoneNumber: event.phoneNumber);

      emit(const SendCodeState.success());
    } catch (e, s) {
      addError(e, s);

      emit(const SendCodeState.error());
    } finally {
      emit(const SendCodeState.initial());
    }
  }
}