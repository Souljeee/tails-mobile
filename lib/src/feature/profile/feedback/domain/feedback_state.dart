part of 'feedback_bloc.dart';

typedef FeedbackStateMatch<T, S extends FeedbackState> = T Function(S state);

sealed class FeedbackState extends Equatable {
  const FeedbackState();

  const factory FeedbackState.initial() = FeedbackState$Initial;

  const factory FeedbackState.sending() = FeedbackState$Sending;

  const factory FeedbackState.sent() = FeedbackState$Sent;

  /// [isRateLimited] — слишком много обращений подряд.
  const factory FeedbackState.failure({bool isRateLimited}) = FeedbackState$Failure;

  T map<T>({
    required FeedbackStateMatch<T, FeedbackState$Initial> initial,
    required FeedbackStateMatch<T, FeedbackState$Sending> sending,
    required FeedbackStateMatch<T, FeedbackState$Sent> sent,
    required FeedbackStateMatch<T, FeedbackState$Failure> failure,
  }) => switch (this) {
    final FeedbackState$Initial state => initial(state),
    final FeedbackState$Sending state => sending(state),
    final FeedbackState$Sent state => sent(state),
    final FeedbackState$Failure state => failure(state),
  };

  T? mapOrNull<T>({
    FeedbackStateMatch<T, FeedbackState$Initial>? initial,
    FeedbackStateMatch<T, FeedbackState$Sending>? sending,
    FeedbackStateMatch<T, FeedbackState$Sent>? sent,
    FeedbackStateMatch<T, FeedbackState$Failure>? failure,
  }) => map<T?>(
    initial: initial ?? (_) => null,
    sending: sending ?? (_) => null,
    sent: sent ?? (_) => null,
    failure: failure ?? (_) => null,
  );
}

final class FeedbackState$Initial extends FeedbackState {
  const FeedbackState$Initial();

  @override
  List<Object?> get props => [];
}

final class FeedbackState$Sending extends FeedbackState {
  const FeedbackState$Sending();

  @override
  List<Object?> get props => [];
}

final class FeedbackState$Sent extends FeedbackState {
  const FeedbackState$Sent();

  @override
  List<Object?> get props => [];
}

final class FeedbackState$Failure extends FeedbackState {
  const FeedbackState$Failure({this.isRateLimited = false});

  final bool isRateLimited;

  @override
  List<Object?> get props => [isRateLimited];
}
