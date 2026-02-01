part of 'add_pet_bloc.dart';

typedef AddPetEventMatch<T, S extends AddPetEvent> = T Function(S event);

sealed class AddPetEvent extends Equatable {
  const AddPetEvent();

  const factory AddPetEvent.addingRequested({
    required String name,
    required PetTypeEnum petType,
    required String breed,
    required String color,
    required String weight,
    required PetSexEnum sex,
    required DateTime birthDate,
    required bool castration,
    required Uint8List? image,
  }) = AddPetEvent$AddingRequested;

  T map<T>({
    required AddPetEventMatch<T, AddPetEvent$AddingRequested> addingRequested,
  }) =>
      switch (this) {
        final AddPetEvent$AddingRequested event => addingRequested(event),
      };
}

final class AddPetEvent$AddingRequested extends AddPetEvent {
  final String name;
  final PetTypeEnum petType;
  final String breed;
  final String color;
  final String weight;
  final PetSexEnum sex;
  final DateTime birthDate;
  final bool castration;
  final Uint8List? image;

  const AddPetEvent$AddingRequested({
    required this.name,
    required this.petType,
    required this.breed,
    required this.color,
    required this.weight,
    required this.sex,
    required this.birthDate,
    required this.castration,
    this.image,
  });

  @override
  List<Object?> get props => [
        name,
        petType,
        breed,
        color,
        weight,
        sex,
        birthDate,
        castration,
        image,
      ];
}
