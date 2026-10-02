part of 'pets_overview_bloc.dart';

typedef PetsOverviewEventMatch<T, S extends PetsOverviewEvent> = T Function(S event);

sealed class PetsOverviewEvent extends Equatable {
  const PetsOverviewEvent();

  /// [silent] — обновить данные, не показывая загрузку, если они уже есть.
  /// [completer] завершается, когда обработка закончена (для pull-to-refresh).
  const factory PetsOverviewEvent.fetchRequested({bool silent, Completer<void>? completer}) =
      PetsOverviewEvent$FetchRequested;

  T map<T>({required PetsOverviewEventMatch<T, PetsOverviewEvent$FetchRequested> fetchRequested}) =>
      switch (this) {
        final PetsOverviewEvent$FetchRequested event => fetchRequested(event),
      };
}

final class PetsOverviewEvent$FetchRequested extends PetsOverviewEvent {
  const PetsOverviewEvent$FetchRequested({this.silent = false, this.completer});

  final bool silent;
  final Completer<void>? completer;

  @override
  List<Object?> get props => [silent];
}
