part of 'pets_bloc.dart';

typedef PetsEventMatch<T, S extends PetsEvent> = T Function(S event);

sealed class PetsEvent extends Equatable {
  const PetsEvent();

  const factory PetsEvent.petsRequested() = PetsEvent$PetsRequested;

  T map<T>({
    required PetsEventMatch<T, PetsEvent$PetsRequested> petsRequested,
  }) =>
      switch (this) {
        final PetsEvent$PetsRequested event => petsRequested(event),
      };
}

final class PetsEvent$PetsRequested extends PetsEvent {
  const PetsEvent$PetsRequested();

  @override
  List<Object?> get props => [];
}