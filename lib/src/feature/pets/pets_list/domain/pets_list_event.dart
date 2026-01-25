part of 'pets_list_bloc.dart';

typedef PetsListEventMatch<T, S extends PetsListEvent> = T Function(S event);

sealed class PetsListEvent extends Equatable {
  const PetsListEvent();

  const factory PetsListEvent.fetchRequested() = PetsListEvent$FetchRequested;

  T map<T>({
    required PetsListEventMatch<T, PetsListEvent$FetchRequested> fetchRequested,
  }) =>
      switch (this) {
        final PetsListEvent$FetchRequested event => fetchRequested(event),
      };
}

final class PetsListEvent$FetchRequested extends PetsListEvent {
  const PetsListEvent$FetchRequested();

  @override
  List<Object?> get props => [];
}
