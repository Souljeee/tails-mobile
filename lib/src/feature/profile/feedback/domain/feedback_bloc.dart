import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/feedback_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/feedback_topic.dart';
import 'package:tails_mobile/src/feature/profile/core/exceptions/profile_exceptions.dart';

part 'feedback_event.dart';
part 'feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  FeedbackBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const FeedbackState.initial()) {
    on<FeedbackEvent>(
      (event, emit) => event.map(sendRequested: (event) => _onSendRequested(event, emit)),
    );
  }

  final ProfileRepository _profileRepository;

  Future<void> _onSendRequested(
    FeedbackEvent$SendRequested event,
    Emitter<FeedbackState> emit,
  ) async {
    // Повторное нажатие во время отправки не должно создать второе обращение.
    if (state is FeedbackState$Sending) {
      return;
    }

    try {
      emit(const FeedbackState.sending());

      await _profileRepository.sendFeedback(
        FeedbackModel(topic: event.topic, message: event.message, screenshot: event.screenshot),
      );

      emit(const FeedbackState.sent());
    } on FeedbackRateLimitException catch (e, s) {
      addError(e, s);

      emit(const FeedbackState.failure(isRateLimited: true));
    } catch (e, s) {
      addError(e, s);

      emit(const FeedbackState.failure());
    }
  }
}
