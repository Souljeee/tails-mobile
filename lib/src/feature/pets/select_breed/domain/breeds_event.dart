part of 'breeds_bloc.dart';

typedef BreedsEventMatch<T, S extends BreedsEvent> = T Function(S event);

sealed class BreedsEvent extends Equatable {
  const BreedsEvent();

  const factory BreedsEvent.fetchRequested({
    required PetTypeEnum petType,
  }) = BreedsEvent$FetchRequested;

  T map<T>({
    required BreedsEventMatch<T, BreedsEvent$FetchRequested> fetchRequested,
  }) =>
      switch (this) {
        final BreedsEvent$FetchRequested event => fetchRequested(event),
      };
}

final class BreedsEvent$FetchRequested extends BreedsEvent {
  final PetTypeEnum petType;
  const BreedsEvent$FetchRequested({
    required this.petType,
  });

  @override
  List<Object?> get props => [petType];
}
