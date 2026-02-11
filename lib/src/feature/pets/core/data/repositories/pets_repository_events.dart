
import 'package:equatable/equatable.dart';

typedef PetsRepositoryEventsEventMatch<T, S extends PetsRepositoryEventsEvent> = T Function(S event);

sealed class PetsRepositoryEventsEvent extends Equatable {
  const PetsRepositoryEventsEvent();

  const factory PetsRepositoryEventsEvent.petsAdded() = PetsRepositoryEventsEvent$PetsAdded;
  const factory PetsRepositoryEventsEvent.petDeleted() = PetsRepositoryEventsEvent$PetDeleted;
  T map<T>({
    required PetsRepositoryEventsEventMatch<T, PetsRepositoryEventsEvent$PetsAdded> petsAdded,
    required PetsRepositoryEventsEventMatch<T, PetsRepositoryEventsEvent$PetDeleted> petDeleted,
    }) =>
      switch (this) {
        final PetsRepositoryEventsEvent$PetsAdded event => petsAdded(event),
        final PetsRepositoryEventsEvent$PetDeleted event => petDeleted(event),
      };
}

final class PetsRepositoryEventsEvent$PetsAdded extends PetsRepositoryEventsEvent {
  const PetsRepositoryEventsEvent$PetsAdded();

  @override
  List<Object?> get props => [];
}

final class PetsRepositoryEventsEvent$PetDeleted extends PetsRepositoryEventsEvent {
  const PetsRepositoryEventsEvent$PetDeleted();

  @override
  List<Object?> get props => [];
}