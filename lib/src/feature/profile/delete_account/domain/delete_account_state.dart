part of 'delete_account_bloc.dart';

enum DeleteAccountStatus { idle, sendingCode, codeSent, deleting, deleted, failure }

enum DeleteAccountFailure { generic, invalidCode }

class DeleteAccountState extends Equatable {
  const DeleteAccountState({
    this.status = DeleteAccountStatus.idle,
    this.petNames = const [],
    this.failure,
    this.failureMessage,
    this.wasCodeAlreadySent = false,
    this.revision = 0,
  });

  final DeleteAccountStatus status;

  /// Имена питомцев, которые будут удалены вместе с аккаунтом.
  final List<String> petNames;

  final DeleteAccountFailure? failure;

  /// Текст ошибки от сервера (например, «Неверный код»), если он есть.
  final String? failureMessage;

  /// Звонок не повторён, потому что предыдущий код ещё действует.
  final bool wasCodeAlreadySent;

  /// Растёт с каждым новым результатом, чтобы повторная одинаковая ошибка тоже была событием.
  final int revision;

  bool get isBusy =>
      status == DeleteAccountStatus.sendingCode || status == DeleteAccountStatus.deleting;

  DeleteAccountState copyWith({
    DeleteAccountStatus? status,
    List<String>? petNames,
    DeleteAccountFailure? failure,
    String? failureMessage,
    bool wasCodeAlreadySent = false,
  }) => DeleteAccountState(
    status: status ?? this.status,
    petNames: petNames ?? this.petNames,
    failure: failure,
    failureMessage: failureMessage,
    wasCodeAlreadySent: wasCodeAlreadySent,
    revision: revision + 1,
  );

  @override
  List<Object?> get props => [
    status,
    petNames,
    failure,
    failureMessage,
    wasCodeAlreadySent,
    revision,
  ];
}
