part of 'delete_pet_bloc.dart';

typedef DeletePetEventMatch<T, S extends DeletePetEvent> = T Function(S event);

sealed class DeletePetEvent extends Equatable {
  const DeletePetEvent();

  const factory DeletePetEvent.deleteRequested({required int id}) = DeletePetEvent$DeleteRequested;

  T map<T>({
    required DeletePetEventMatch<T, DeletePetEvent$DeleteRequested> deleteRequested,
  }) =>
      switch (this) {
        final DeletePetEvent$DeleteRequested event => deleteRequested(event),
      };
}

final class DeletePetEvent$DeleteRequested extends DeletePetEvent implements TailsLoggable {
  final int id;
  
  const DeletePetEvent$DeleteRequested({required this.id});

  @override
  Map<String, Object?> toLogData() => {'petId': id};

  @override
  List<Object?> get props => [id];
}
