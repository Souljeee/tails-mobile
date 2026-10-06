part of 'edit_profile_bloc.dart';

typedef EditProfileEventMatch<T, S extends EditProfileEvent> = T Function(S event);

sealed class EditProfileEvent extends Equatable {
  const EditProfileEvent();

  /// [name] `null` — имя не менялось; [avatar] — новое фото; [removeAvatar] — удалить текущее.
  ///
  /// [hadAvatar] — было ли фото до изменения; нужно только аналитике.
  const factory EditProfileEvent.saveRequested({
    String? name,
    File? avatar,
    bool removeAvatar,
    bool hadAvatar,
  }) = EditProfileEvent$SaveRequested;

  T map<T>({required EditProfileEventMatch<T, EditProfileEvent$SaveRequested> saveRequested}) =>
      switch (this) {
        final EditProfileEvent$SaveRequested event => saveRequested(event),
      };

  T? mapOrNull<T>({EditProfileEventMatch<T, EditProfileEvent$SaveRequested>? saveRequested}) =>
      map<T?>(saveRequested: saveRequested ?? (_) => null);
}

final class EditProfileEvent$SaveRequested extends EditProfileEvent {
  const EditProfileEvent$SaveRequested({
    this.name,
    this.avatar,
    this.removeAvatar = false,
    this.hadAvatar = false,
  });

  final String? name;
  final File? avatar;
  final bool removeAvatar;
  final bool hadAvatar;

  @override
  List<Object?> get props => [name, avatar, removeAvatar, hadAvatar];
}
