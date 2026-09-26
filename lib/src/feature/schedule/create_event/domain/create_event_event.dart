part of 'create_event_bloc.dart';

typedef CreateEventEventMatch<T, S extends CreateEventEvent> = T Function(S event);

sealed class CreateEventEvent extends Equatable {
  const CreateEventEvent();

  const factory CreateEventEvent.createRequested({required CreateEventModel model}) = CreateEventEvent$CreateRequested;

  T map<T>({
    required CreateEventEventMatch<T, CreateEventEvent$CreateRequested> createRequested,
  }) =>
      switch (this) {
        final CreateEventEvent$CreateRequested event => createRequested(event),
      };
}

final class CreateEventEvent$CreateRequested extends CreateEventEvent {
  final CreateEventModel model;
  
  const CreateEventEvent$CreateRequested({required this.model});

  @override
  List<Object?> get props => [model];
}