part of 'pet_details_bloc.dart';

typedef PetDetailsEventMatch<T, S extends PetDetailsEvent> = T Function(S event);

sealed class PetDetailsEvent extends Equatable {
  const PetDetailsEvent();

  const factory PetDetailsEvent.fetchRequested({required int id}) = PetDetailsEvent$FetchRequested;

  T map<T>({
    required PetDetailsEventMatch<T, PetDetailsEvent$FetchRequested> fetchRequested,
  }) =>
      switch (this) {
        final PetDetailsEvent$FetchRequested event => fetchRequested(event),
      };
}

final class PetDetailsEvent$FetchRequested extends PetDetailsEvent {
  final int id;

  const PetDetailsEvent$FetchRequested({required this.id});

  @override
  List<Object?> get props => [id];
}
