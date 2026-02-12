part of 'edit_pet_bloc.dart';

typedef EditPetEventMatch<T, S extends EditPetEvent> = T Function(S event);

sealed class EditPetEvent extends Equatable {
  const EditPetEvent();

  const factory EditPetEvent.editingRequested({
    required int petId,
    required EditPetModel pet,
    required File? image,
  }) = EditPetEvent$EditingRequested;

  T map<T>({required EditPetEventMatch<T, EditPetEvent$EditingRequested> editingRequested}) =>
      switch (this) {
        final EditPetEvent$EditingRequested event => editingRequested(event),
      };
}

final class EditPetEvent$EditingRequested extends EditPetEvent {
  final int petId;
  final EditPetModel pet;
  final File? image;

  const EditPetEvent$EditingRequested({
    required this.petId,
    required this.pet,
    required this.image,
  });

  @override
  List<Object?> get props => [petId, pet, image];
}
