part of 'edit_event_bloc.dart';

sealed class EditEventState extends Equatable {
  const EditEventState();

  const factory EditEventState.idle() = EditEventState$Idle;
  const factory EditEventState.loading() = EditEventState$Loading;
  const factory EditEventState.success(EditOccurrenceResult result) = EditEventState$Success;
  const factory EditEventState.error() = EditEventState$Error;

  bool get isLoading => this is EditEventState$Loading;

  @override
  List<Object?> get props => [];
}

final class EditEventState$Idle extends EditEventState {
  const EditEventState$Idle();
}

final class EditEventState$Loading extends EditEventState {
  const EditEventState$Loading();
}

final class EditEventState$Success extends EditEventState {
  const EditEventState$Success(this.result);

  final EditOccurrenceResult result;

  @override
  List<Object?> get props => [result];
}

final class EditEventState$Error extends EditEventState {
  const EditEventState$Error();
}
