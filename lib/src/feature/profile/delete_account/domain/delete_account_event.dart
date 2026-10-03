part of 'delete_account_bloc.dart';

typedef DeleteAccountEventMatch<T, S extends DeleteAccountEvent> = T Function(S event);

sealed class DeleteAccountEvent extends Equatable {
  const DeleteAccountEvent();

  /// Загрузить имена питомцев для предупреждения.
  const factory DeleteAccountEvent.started() = DeleteAccountEvent$Started;

  /// Позвонить с кодом подтверждения.
  const factory DeleteAccountEvent.sendCodeRequested() = DeleteAccountEvent$SendCodeRequested;

  const factory DeleteAccountEvent.deleteRequested({required String code}) =
      DeleteAccountEvent$DeleteRequested;

  T map<T>({
    required DeleteAccountEventMatch<T, DeleteAccountEvent$Started> started,
    required DeleteAccountEventMatch<T, DeleteAccountEvent$SendCodeRequested> sendCodeRequested,
    required DeleteAccountEventMatch<T, DeleteAccountEvent$DeleteRequested> deleteRequested,
  }) => switch (this) {
    final DeleteAccountEvent$Started event => started(event),
    final DeleteAccountEvent$SendCodeRequested event => sendCodeRequested(event),
    final DeleteAccountEvent$DeleteRequested event => deleteRequested(event),
  };

  T? mapOrNull<T>({
    DeleteAccountEventMatch<T, DeleteAccountEvent$Started>? started,
    DeleteAccountEventMatch<T, DeleteAccountEvent$SendCodeRequested>? sendCodeRequested,
    DeleteAccountEventMatch<T, DeleteAccountEvent$DeleteRequested>? deleteRequested,
  }) => map<T?>(
    started: started ?? (_) => null,
    sendCodeRequested: sendCodeRequested ?? (_) => null,
    deleteRequested: deleteRequested ?? (_) => null,
  );
}

final class DeleteAccountEvent$Started extends DeleteAccountEvent {
  const DeleteAccountEvent$Started();

  @override
  List<Object?> get props => [];
}

final class DeleteAccountEvent$SendCodeRequested extends DeleteAccountEvent {
  const DeleteAccountEvent$SendCodeRequested();

  @override
  List<Object?> get props => [];
}

final class DeleteAccountEvent$DeleteRequested extends DeleteAccountEvent {
  const DeleteAccountEvent$DeleteRequested({required this.code});

  final String code;

  @override
  List<Object?> get props => [code];
}
