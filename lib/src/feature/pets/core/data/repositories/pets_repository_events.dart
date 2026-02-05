
import 'package:equatable/equatable.dart';

typedef PetsRepositoryEventsEventMatch<T, S extends PetsRepositoryEventsEvent> = T Function(S event);

sealed class PetsRepositoryEventsEvent extends Equatable {
  const PetsRepositoryEventsEvent();

  const factory PetsRepositoryEventsEvent.petsAdded() = PetsRepositoryEventsEvent$PetsAdded;

  T map<T>({
    required PetsRepositoryEventsEventMatch<T, PetsRepositoryEventsEvent$PetsAdded> petsAdded,
    }) =>
      switch (this) {
        final PetsRepositoryEventsEvent$PetsAdded event => petsAdded(event),
      };
}

final class PetsRepositoryEventsEvent$PetsAdded extends PetsRepositoryEventsEvent {
  const PetsRepositoryEventsEvent$PetsAdded();

  @override
  List<Object?> get props => [];
}