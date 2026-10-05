part of 'feedback_bloc.dart';

typedef FeedbackEventMatch<T, S extends FeedbackEvent> = T Function(S event);

sealed class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  const factory FeedbackEvent.sendRequested({
    required FeedbackTopic topic,
    required String message,
    File? screenshot,
    bool attachLogs,
  }) = FeedbackEvent$SendRequested;

  T map<T>({required FeedbackEventMatch<T, FeedbackEvent$SendRequested> sendRequested}) =>
      switch (this) {
        final FeedbackEvent$SendRequested event => sendRequested(event),
      };

  T? mapOrNull<T>({FeedbackEventMatch<T, FeedbackEvent$SendRequested>? sendRequested}) =>
      map<T?>(sendRequested: sendRequested ?? (_) => null);
}

final class FeedbackEvent$SendRequested extends FeedbackEvent {
  const FeedbackEvent$SendRequested({
    required this.topic,
    required this.message,
    this.screenshot,
    this.attachLogs = false,
  });

  final FeedbackTopic topic;
  final String message;
  final File? screenshot;

  /// Приложить ли журнал работы приложения.
  final bool attachLogs;

  @override
  List<Object?> get props => [topic, message, screenshot, attachLogs];
}
