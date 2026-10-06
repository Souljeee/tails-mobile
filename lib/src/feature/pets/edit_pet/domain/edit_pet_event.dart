part of 'edit_pet_bloc.dart';

typedef EditPetEventMatch<T, S extends EditPetEvent> = T Function(S event);

sealed class EditPetEvent extends Equatable {
  const EditPetEvent();

  const factory EditPetEvent.editingRequested({
    required int petId,
    required EditPetModel pet,
    required File? image,
    List<String> changedFields,
  }) = EditPetEvent$EditingRequested;

  T map<T>({required EditPetEventMatch<T, EditPetEvent$EditingRequested> editingRequested}) =>
      switch (this) {
        final EditPetEvent$EditingRequested event => editingRequested(event),
      };
}

final class EditPetEvent$EditingRequested extends EditPetEvent implements TailsLoggable {
  final int petId;
  final EditPetModel pet;
  final File? image;

  /// Какие поля изменил пользователь (`name`, `breed`, ...). Нужно только аналитике.
  final List<String> changedFields;

  const EditPetEvent$EditingRequested({
    required this.petId,
    required this.pet,
    required this.image,
    this.changedFields = const [],
  });

  @override
  Map<String, Object?> toLogData() => {'petId': petId, 'hasNewImage': image != null};

  @override
  List<Object?> get props => [petId, pet, image, changedFields];
}
