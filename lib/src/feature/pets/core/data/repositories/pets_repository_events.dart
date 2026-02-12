
import 'package:equatable/equatable.dart';

typedef PetsRepositoryEventsEventMatch<T, S extends PetsRepositoryEventsEvent> = T Function(S event);

sealed class PetsRepositoryEventsEvent extends Equatable {
  const PetsRepositoryEventsEvent();

  const factory PetsRepositoryEventsEvent.petsAdded() = PetsRepositoryEventsEvent$PetsAdded;

  const factory PetsRepositoryEventsEvent.petEdited() = PetsRepositoryEventsEvent$PetEdited;

  T map<T>({
    required PetsRepositoryEventsEventMatch<T, PetsRepositoryEventsEvent$PetsAdded> petsAdded,
    required PetsRepositoryEventsEventMatch<T, PetsRepositoryEventsEvent$PetEdited> petEdited,
    }) =>
      switch (this) {
        final PetsRepositoryEventsEvent$PetsAdded event => petsAdded(event),
        final PetsRepositoryEventsEvent$PetEdited event => petEdited(event),
      };
}

final class PetsRepositoryEventsEvent$PetsAdded extends PetsRepositoryEventsEvent {
  const PetsRepositoryEventsEvent$PetsAdded();

  @override
  List<Object?> get props => [];
}

final class PetsRepositoryEventsEvent$PetEdited extends PetsRepositoryEventsEvent {
  const PetsRepositoryEventsEvent$PetEdited();

  @override
  List<Object?> get props => [];
}