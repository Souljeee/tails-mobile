import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'code_timer_event.dart';
part 'code_timer_state.dart';

class CodeTimerBloc extends Bloc<CodeTimerEvent, CodeTimerState> {
  Timer? _timer;
  static const _duration = 60;

  CodeTimerBloc() : super(const CodeTimerState.idle()) {
    on<CodeTimerEvent>(
      (event, emit) => event.map(
        started: (event) => _onStarted(event, emit),
        ticked: (event) => _onTicked(event, emit),
        reset: (event) => _onReset(event, emit),
      ),
    );
  }

  void _onStarted(
    CodeTimerEvent$Started event,
    Emitter<CodeTimerState> emit,
  ) {
    _timer?.cancel();
    
    emit(const CodeTimerState.ticking(secondsRemaining: _duration));
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(const CodeTimerEvent.ticked());
    });
  }

  void _onTicked(
    CodeTimerEvent$Ticked event,
    Emitter<CodeTimerState> emit,
  ) {
    final newSeconds = state.secondsRemaining - 1;

    if (newSeconds <= 0) {
      _timer?.cancel();
      emit(const CodeTimerState.idle());
    } else {
      emit(CodeTimerState.ticking(secondsRemaining: newSeconds));
    }
  }

  void _onReset(
    CodeTimerEvent$Reset event,
    Emitter<CodeTimerState> emit,
  ) {
    _timer?.cancel();
    emit(const CodeTimerState.idle());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
