part of 'feedback_bloc.dart';

typedef FeedbackEventMatch<T, S extends FeedbackEvent> = T Function(S event);

sealed class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  const factory FeedbackEvent.sendRequested({
    required FeedbackTopic topic,
    required String message,
    File? screenshot,
  }) = FeedbackEvent$SendRequested;

  T map<T>({required FeedbackEventMatch<T, FeedbackEvent$SendRequested> sendRequested}) =>
      switch (this) {
        final FeedbackEvent$SendRequested event => sendRequested(event),
      };

  T? mapOrNull<T>({FeedbackEventMatch<T, FeedbackEvent$SendRequested>? sendRequested}) =>
      map<T?>(sendRequested: sendRequested ?? (_) => null);
}

final class FeedbackEvent$SendRequested extends FeedbackEvent {
  const FeedbackEvent$SendRequested({required this.topic, required this.message, this.screenshot});

  final FeedbackTopic topic;
  final String message;
  final File? screenshot;

  @override
  List<Object?> get props => [topic, message, screenshot];
}
