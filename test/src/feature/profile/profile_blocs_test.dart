import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/pets_repository_events.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/notification_settings_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/profile_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/feedback_topic.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';
import 'package:tails_mobile/src/feature/profile/core/exceptions/profile_exceptions.dart';
import 'package:tails_mobile/src/feature/profile/delete_account/domain/delete_account_bloc.dart';
import 'package:tails_mobile/src/feature/profile/edit_profile/domain/edit_profile_bloc.dart';
import 'package:tails_mobile/src/feature/profile/feedback/domain/feedback_bloc.dart';
import 'package:tails_mobile/src/feature/profile/notifications_settings/domain/notifications_settings_bloc.dart';
import 'package:tails_mobile/src/feature/profile/profile_overview/domain/profile_overview_bloc.dart';

import '../../../helpers/profile_fakes.dart';

/// Ждёт, пока состояние блока начнёт удовлетворять [test].
Future<S> _until<S>(Stream<S> stream, bool Function(S state) test) =>
    stream.firstWhere(test).timeout(const Duration(seconds: 2));

void main() {
  group('NotificationsSettingsBloc', () {
    late FakeProfileRepository repository;
    late NotificationsSettingsBloc bloc;

    setUp(() {
      repository = FakeProfileRepository();
      bloc = NotificationsSettingsBloc(profileRepository: repository);
    });

    tearDown(() => bloc.close());

    test('загружает настройки и состояние системного разрешения', () async {
      repository
        ..blocked = true
        ..settings = repository.settings.copyWith(
          category: NotificationCategory.feeding,
          value: false,
        );

      bloc.add(const NotificationsSettingsEvent.started());
      final state = await _until(bloc.stream, (s) => s.status == NotificationsSettingsStatus.ready);

      expect(state.isBlockedBySystem, isTrue);
      expect(state.settings!.isEnabled(NotificationCategory.feeding), isFalse);
      expect(state.settings!.isEnabled(NotificationCategory.walks), isTrue);
    });

    test('при ошибке загрузки показывает failure', () async {
      repository.settings = NotificationSettingsModel.allEnabled();
      final failing = NotificationsSettingsBloc(profileRepository: ThrowingSettingsRepository());

      failing.add(const NotificationsSettingsEvent.started());
      final state = await _until(
        failing.stream,
        (s) => s.status == NotificationsSettingsStatus.failure,
      );

      expect(state.settings, isNull);

      await failing.close();
    });

    test('переключатель срабатывает сразу, а сервер подтверждает значение', () async {
      bloc.add(const NotificationsSettingsEvent.started());
      await _until(bloc.stream, (s) => s.status == NotificationsSettingsStatus.ready);

      repository.setNotificationGate = Completer<void>();
      bloc.add(
        const NotificationsSettingsEvent.toggled(
          category: NotificationCategory.walks,
          enabled: false,
        ),
      );

      final optimistic = await _until(bloc.stream, (s) => s.savingCategories.isNotEmpty);
      expect(optimistic.settings!.isEnabled(NotificationCategory.walks), isFalse);

      repository.setNotificationGate!.complete();
      final confirmed = await _until(bloc.stream, (s) => s.savingCategories.isEmpty);

      expect(confirmed.settings!.isEnabled(NotificationCategory.walks), isFalse);
      expect(confirmed.saveFailures, 0);
    });

    test('при ошибке сервера возвращает прежнее значение и сообщает об ошибке', () async {
      bloc.add(const NotificationsSettingsEvent.started());
      await _until(bloc.stream, (s) => s.status == NotificationsSettingsStatus.ready);

      repository.setNotificationError = Exception('offline');
      bloc.add(
        const NotificationsSettingsEvent.toggled(
          category: NotificationCategory.vaccinations,
          enabled: false,
        ),
      );

      final state = await _until(bloc.stream, (s) => s.saveFailures == 1);

      expect(state.settings!.isEnabled(NotificationCategory.vaccinations), isTrue);
      expect(state.savingCategories, isEmpty);
    });

    test('повторное нажатие на ту же категорию во время сохранения игнорируется', () async {
      bloc.add(const NotificationsSettingsEvent.started());
      await _until(bloc.stream, (s) => s.status == NotificationsSettingsStatus.ready);

      repository.setNotificationGate = Completer<void>();
      const toggle = NotificationsSettingsEvent.toggled(
        category: NotificationCategory.walks,
        enabled: false,
      );

      bloc
        ..add(toggle)
        ..add(toggle);
      await _until(bloc.stream, (s) => s.savingCategories.isNotEmpty);
      repository.setNotificationGate!.complete();
      await _until(bloc.stream, (s) => s.savingCategories.isEmpty);

      expect(repository.calls.where((c) => c.startsWith('set(')), hasLength(1));
    });

    test('перепроверка разрешения обновляет баннер', () async {
      bloc.add(const NotificationsSettingsEvent.started());
      await _until(bloc.stream, (s) => s.status == NotificationsSettingsStatus.ready);

      repository.blocked = true;
      bloc.add(const NotificationsSettingsEvent.systemStatusChecked());
      final state = await _until(bloc.stream, (s) => s.isBlockedBySystem);

      expect(state.isBlockedBySystem, isTrue);
    });
  });

  group('DeleteAccountBloc', () {
    late FakeProfileRepository repository;
    late FakePetRepository pets;
    late DeleteAccountBloc bloc;

    setUp(() {
      repository = FakeProfileRepository();
      pets = FakePetRepository();
      bloc = DeleteAccountBloc(profileRepository: repository, petRepository: pets);
    });

    tearDown(() => bloc.close());

    test('собирает имена настоящих питомцев', () async {
      pets.pets = [fakePet(1, 'Барсик'), fakePet(2, 'Мурка')];

      bloc.add(const DeleteAccountEvent.started());
      final state = await _until(bloc.stream, (s) => s.petNames.isNotEmpty);

      expect(state.petNames, ['Барсик', 'Мурка']);
    });

    test('звонок с кодом переводит в состояние codeSent', () async {
      bloc.add(const DeleteAccountEvent.sendCodeRequested());
      final state = await _until(bloc.stream, (s) => s.status == DeleteAccountStatus.codeSent);

      expect(state.wasCodeAlreadySent, isFalse);
      expect(repository.calls, ['sendDeletionCode']);
    });

    test('слишком ранний повтор не блокирует ввод уже отправленного кода', () async {
      repository.sendCodeError = const DeletionCodeTooSoonException();

      bloc.add(const DeleteAccountEvent.sendCodeRequested());
      final state = await _until(bloc.stream, (s) => s.status == DeleteAccountStatus.codeSent);

      expect(state.wasCodeAlreadySent, isTrue);
    });

    test('другая ошибка отправки кода — общая ошибка', () async {
      repository.sendCodeError = Exception('offline');

      bloc.add(const DeleteAccountEvent.sendCodeRequested());
      final state = await _until(bloc.stream, (s) => s.status == DeleteAccountStatus.failure);

      expect(state.failure, DeleteAccountFailure.generic);
    });

    test('неверный код показывает сообщение сервера', () async {
      repository.deleteError = const InvalidDeletionCodeException(message: 'Неверный код');

      bloc.add(const DeleteAccountEvent.deleteRequested(code: '1234'));
      final state = await _until(bloc.stream, (s) => s.status == DeleteAccountStatus.failure);

      expect(state.failure, DeleteAccountFailure.invalidCode);
      expect(state.failureMessage, 'Неверный код');
    });

    test('верный код удаляет аккаунт один раз, даже при двойном нажатии', () async {
      repository.deleteGate = Completer<void>();

      bloc
        ..add(const DeleteAccountEvent.deleteRequested(code: '1234'))
        ..add(const DeleteAccountEvent.deleteRequested(code: '1234'));
      await _until(bloc.stream, (s) => s.status == DeleteAccountStatus.deleting);
      repository.deleteGate!.complete();
      await _until(bloc.stream, (s) => s.status == DeleteAccountStatus.deleted);

      expect(repository.calls.where((c) => c.startsWith('deleteAccount')), hasLength(1));
    });
  });

  group('FeedbackBloc', () {
    late FakeProfileRepository repository;
    late FeedbackBloc bloc;

    setUp(() {
      repository = FakeProfileRepository();
      bloc = FeedbackBloc(profileRepository: repository);
    });

    tearDown(() => bloc.close());

    const request = FeedbackEvent.sendRequested(topic: FeedbackTopic.idea, message: 'Привет');

    test('успешная отправка', () async {
      bloc.add(request);
      await _until(bloc.stream, (s) => s is FeedbackState$Sent);

      expect(repository.calls, ['sendFeedback(idea, Привет)']);
    });

    test('двойное нажатие отправляет одно обращение', () async {
      repository.feedbackGate = Completer<void>();

      bloc
        ..add(request)
        ..add(request);
      await _until(bloc.stream, (s) => s is FeedbackState$Sending);
      repository.feedbackGate!.complete();
      await _until(bloc.stream, (s) => s is FeedbackState$Sent);

      expect(repository.calls, hasLength(1));
    });

    test('ограничение частоты отличается от прочих ошибок', () async {
      repository.feedbackError = const FeedbackRateLimitException();

      bloc.add(request);
      final state = await _until(bloc.stream, (s) => s is FeedbackState$Failure);

      expect((state as FeedbackState$Failure).isRateLimited, isTrue);
    });

    test('сетевая ошибка — обычная ошибка', () async {
      repository.feedbackError = Exception('offline');

      bloc.add(request);
      final state = await _until(bloc.stream, (s) => s is FeedbackState$Failure);

      expect((state as FeedbackState$Failure).isRateLimited, isFalse);
    });
  });

  group('EditProfileBloc', () {
    late FakeProfileRepository repository;
    late EditProfileBloc bloc;

    setUp(() {
      repository = FakeProfileRepository();
      bloc = EditProfileBloc(profileRepository: repository);
    });

    tearDown(() => bloc.close());

    test('удаление фото без замены не трогает имя', () async {
      bloc.add(const EditProfileEvent.saveRequested(removeAvatar: true));
      await _until(bloc.stream, (s) => s is EditProfileState$Success);

      expect(repository.calls, ['deleteAvatar']);
    });

    test('новое фото заменяет старое без отдельного удаления', () async {
      final photo = File('/tmp/photo.jpg');

      bloc.add(EditProfileEvent.saveRequested(name: 'Аня', avatar: photo, removeAvatar: true));
      await _until(bloc.stream, (s) => s is EditProfileState$Success);

      expect(repository.calls, ['updateProfile(name: Аня, avatar: /tmp/photo.jpg)']);
    });

    test('очистка имени отправляется пустой строкой', () async {
      bloc.add(const EditProfileEvent.saveRequested(name: ''));
      await _until(bloc.stream, (s) => s is EditProfileState$Success);

      expect(repository.calls, ['updateProfile(name: , avatar: null)']);
    });

    test('отказ сервера по данным отличается от общей ошибки', () async {
      repository.updateError = const ProfileValidationException();

      bloc.add(const EditProfileEvent.saveRequested(name: 'Аня'));
      final state = await _until(bloc.stream, (s) => s is EditProfileState$Error);

      expect((state as EditProfileState$Error).isValidation, isTrue);
    });
  });

  group('ProfileOverviewBloc', () {
    late FakeProfileRepository repository;
    late FakePetRepository pets;
    late ProfileOverviewBloc bloc;

    setUp(() {
      repository = FakeProfileRepository();
      pets = FakePetRepository()..pets = [fakePet(1, 'Барсик'), fakePet(2, 'Мурка')];
      bloc = ProfileOverviewBloc(profileRepository: repository, petRepository: pets);
    });

    tearDown(() => bloc.close());

    test('показывает профиль и число питомцев', () async {
      bloc.add(const ProfileOverviewEvent.fetchRequested());
      final state = await _until(bloc.stream, (s) => s is ProfileOverviewState$Success);

      final overview = (state as ProfileOverviewState$Success).overview;
      expect(overview.profile.name, 'Анна');
      expect(overview.petsCount, 2);
    });

    test('ошибка списка питомцев не ломает профиль', () async {
      pets.error = Exception('offline');

      bloc.add(const ProfileOverviewEvent.fetchRequested());
      final state = await _until(bloc.stream, (s) => s is ProfileOverviewState$Success);

      expect((state as ProfileOverviewState$Success).overview.petsCount, isNull);
    });

    test('ошибка профиля — экран ошибки', () async {
      repository.profileError = Exception('offline');

      bloc.add(const ProfileOverviewEvent.fetchRequested());

      await _until(bloc.stream, (s) => s is ProfileOverviewState$Error);
    });

    test('тихое обновление при ошибке оставляет показанные данные', () async {
      bloc.add(const ProfileOverviewEvent.fetchRequested());
      await _until(bloc.stream, (s) => s is ProfileOverviewState$Success);

      repository.profileError = Exception('offline');
      bloc.add(const ProfileOverviewEvent.fetchRequested(silent: true));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(bloc.state, isA<ProfileOverviewState$Success>());
    });

    test('перечитывает данные, когда профиль или питомцы изменились', () async {
      bloc.add(const ProfileOverviewEvent.fetchRequested());
      await _until(bloc.stream, (s) => s is ProfileOverviewState$Success);

      repository.profile = ProfileModel(
        id: 'u1',
        phoneNumber: '79990001122',
        name: 'Мария',
        notificationSettings: NotificationSettingsModel.allEnabled(),
      );
      repository.events.add(ProfileRepositoryEvent.profileUpdated);

      final updated = await _until(
        bloc.stream,
        (s) => s is ProfileOverviewState$Success && s.overview.profile.name == 'Мария',
      );
      expect(updated, isA<ProfileOverviewState$Success>());

      pets.pets = [fakePet(1, 'Барсик')];
      pets.events.add(const PetsRepositoryEventsEvent.petDeleted());

      final afterPetChange = await _until(
        bloc.stream,
        (s) => s is ProfileOverviewState$Success && s.overview.petsCount == 1,
      );
      expect(afterPetChange, isA<ProfileOverviewState$Success>());
    });
  });
}
