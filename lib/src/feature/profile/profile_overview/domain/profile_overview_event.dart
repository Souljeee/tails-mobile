part of 'profile_overview_bloc.dart';

typedef ProfileOverviewEventMatch<T, S extends ProfileOverviewEvent> = T Function(S event);

sealed class ProfileOverviewEvent extends Equatable {
  const ProfileOverviewEvent();

  /// [silent] — обновить данные, не показывая загрузку, если они уже есть. [completer] завершается, когда обработка закончена (для pull-to-refresh).
  const factory ProfileOverviewEvent.fetchRequested({bool silent, Completer<void>? completer}) =
      ProfileOverviewEvent$FetchRequested;

  /// Пользователь выбрал фото прямо на экране профиля: загрузить его.
  const factory ProfileOverviewEvent.avatarSelected({required File avatar}) =
      ProfileOverviewEvent$AvatarSelected;

  T map<T>({
    required ProfileOverviewEventMatch<T, ProfileOverviewEvent$FetchRequested> fetchRequested,
    required ProfileOverviewEventMatch<T, ProfileOverviewEvent$AvatarSelected> avatarSelected,
  }) => switch (this) {
    final ProfileOverviewEvent$FetchRequested event => fetchRequested(event),
    final ProfileOverviewEvent$AvatarSelected event => avatarSelected(event),
  };

  T? mapOrNull<T>({
    ProfileOverviewEventMatch<T, ProfileOverviewEvent$FetchRequested>? fetchRequested,
    ProfileOverviewEventMatch<T, ProfileOverviewEvent$AvatarSelected>? avatarSelected,
  }) => map<T?>(
    fetchRequested: fetchRequested ?? (_) => null,
    avatarSelected: avatarSelected ?? (_) => null,
  );
}

final class ProfileOverviewEvent$FetchRequested extends ProfileOverviewEvent {
  const ProfileOverviewEvent$FetchRequested({this.silent = false, this.completer});

  final bool silent;
  final Completer<void>? completer;

  @override
  List<Object?> get props => [silent];
}

final class ProfileOverviewEvent$AvatarSelected extends ProfileOverviewEvent {
  const ProfileOverviewEvent$AvatarSelected({required this.avatar});

  final File avatar;

  @override
  List<Object?> get props => [avatar];
}
