import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/device_info_data_source.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/notification_permission_data_source.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/profile_remote_data_source.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/feedback_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/profile_repository.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/feedback_topic.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';
import 'package:tails_mobile/src/feature/profile/core/exceptions/profile_exceptions.dart';

import '../../../../../helpers/fake_rest_client.dart';

class _FakeDeviceInfo implements DeviceInfoDataSource {
  @override
  Future<DeviceDetails> load() async =>
      (platform: 'ios', osVersion: 'iOS 18.1', deviceModel: 'iPhone15,2');
}

class _FakePermission implements NotificationPermissionDataSource {
  bool blocked = false;
  int openedSettings = 0;

  @override
  Future<bool> isBlockedBySystem() async => blocked;

  @override
  Future<bool> openSettings() async {
    openedSettings++;

    return true;
  }
}

BackendException _backend(int status, [Object? response]) =>
    BackendException(message: 'status $status', statusCode: status, response: response);

const _profileJson = {
  'id': 'u1',
  'phone_number': '79990001122',
  'name': 'Анна',
  'avatar': 'https://example.com/a.jpg',
  'notification_settings': {
    'walks': true,
    'feeding': false,
    'medications': true,
    'vaccinations': true,
    'vet_visits': false,
  },
};

void main() {
  late FakeRestClient client;
  late _FakePermission permission;
  late ProfileRepository repository;

  setUp(() {
    client = FakeRestClient();
    permission = _FakePermission();
    repository = ProfileRepository(
      remoteDataSource: ProfileRemoteDataSource(restClient: client),
      deviceInfoDataSource: _FakeDeviceInfo(),
      notificationPermissionDataSource: permission,
      packageInfo: PackageInfo(
        appName: 'Хвостики',
        packageName: 'ru.tails',
        version: '1.2.0',
        buildNumber: '45',
      ),
    );
  });

  group('профиль', () {
    test('разбирает ответ сервера', () async {
      client.handler = (_) => _profileJson;

      final profile = await repository.getProfile();

      expect(client.last.method, 'GET');
      expect(client.last.path, '/profile/');
      expect(profile.name, 'Анна');
      expect(profile.avatarUrl, 'https://example.com/a.jpg');
      expect(profile.phoneNumber, '79990001122');
      expect(profile.notificationSettings.isEnabled(NotificationCategory.feeding), isFalse);
      expect(profile.notificationSettings.isEnabled(NotificationCategory.walks), isTrue);
    });

    test('терпимо относится к отсутствию имени, фото и настроек', () async {
      client.handler = (_) => {'id': 'u1', 'phone_number': '79990001122', 'name': null};

      final profile = await repository.getProfile();

      expect(profile.hasName, isFalse);
      expect(profile.hasAvatar, isFalse);
      expect(profile.notificationSettings.isAllDisabled, isFalse);
      expect(NotificationCategory.values.every(profile.notificationSettings.isEnabled), isTrue);
    });

    test('updateProfile отправляет PATCH с именем и фото и сообщает об изменении', () async {
      client.handler = (_) => _profileJson;
      final events = <ProfileRepositoryEvent>[];
      repository.eventStream.listen(events.add);

      await repository.updateProfile(name: 'Анна', avatar: File('/tmp/photo.jpg'));
      await Future<void>.delayed(Duration.zero);

      expect(client.last.method, 'PATCH');
      expect(client.last.path, '/profile/');
      expect(client.last.fields, {'name': 'Анна'});
      expect(client.last.files!.single.field, 'avatar');
      expect(client.last.files!.single.path, '/tmp/photo.jpg');
      expect(events, [ProfileRepositoryEvent.profileUpdated]);
    });

    test('пустое имя уходит на сервер как очистка, а null не отправляется', () async {
      client.handler = (_) => _profileJson;

      await repository.updateProfile(name: '');
      expect(client.last.fields, {'name': ''});

      await repository.updateProfile(avatar: File('/tmp/photo.jpg'));
      expect(client.last.fields, isEmpty);
    });

    test('400 при сохранении превращается в ProfileValidationException', () async {
      client.handler = (_) => throw _backend(400, {'detail': 'Не удалось прочитать изображение.'});

      await expectLater(
        repository.updateProfile(name: 'Анна'),
        throwsA(
          isA<ProfileValidationException>().having(
            (e) => e.message,
            'message',
            'Не удалось прочитать изображение.',
          ),
        ),
      );
    });

    test('deleteAvatar вызывает DELETE /profile/avatar/', () async {
      await repository.deleteAvatar();

      expect(client.last.method, 'DELETE');
      expect(client.last.path, '/profile/avatar/');
    });
  });

  group('уведомления', () {
    test('setNotificationEnabled шлёт одну категорию по её ключу', () async {
      client.handler = (_) => {
        'walks': true,
        'feeding': true,
        'medications': true,
        'vaccinations': true,
        'vet_visits': false,
      };

      final settings = await repository.setNotificationEnabled(
        category: NotificationCategory.vetVisits,
        enabled: false,
      );

      expect(client.last.method, 'PATCH');
      expect(client.last.path, '/profile/notification-settings/');
      expect(client.last.body, {'vet_visits': false});
      expect(settings.isEnabled(NotificationCategory.vetVisits), isFalse);
      expect(settings.isEnabled(NotificationCategory.walks), isTrue);
    });

    test('запрет в системе берётся из источника разрешений', () async {
      expect(await repository.isNotificationBlockedBySystem(), isFalse);

      permission.blocked = true;
      expect(await repository.isNotificationBlockedBySystem(), isTrue);

      await repository.openSystemSettings();
      expect(permission.openedSettings, 1);
    });
  });

  group('удаление аккаунта', () {
    test('sendDeletionCode возвращает таймаут повтора из ответа', () async {
      client.handler = (_) => {'detail': 'ok', 'resend_timeout': 42};

      expect(await repository.sendDeletionCode(), 42);
      expect(client.last.method, 'POST');
      expect(client.last.path, '/profile/delete/send-code/');
    });

    test('без resend_timeout берётся минута', () async {
      client.handler = (_) => {'detail': 'ok'};

      expect(await repository.sendDeletionCode(), 60);
    });

    test('429 превращается в DeletionCodeTooSoonException', () async {
      client.handler = (_) => throw _backend(429);

      await expectLater(
        repository.sendDeletionCode(),
        throwsA(isA<DeletionCodeTooSoonException>()),
      );
    });

    test('deleteAccount отправляет код в теле POST', () async {
      await repository.deleteAccount(code: '1234');

      expect(client.last.method, 'POST');
      expect(client.last.path, '/profile/delete/');
      expect(client.last.body, {'code': '1234'});
    });

    test('неверный код превращается в InvalidDeletionCodeException с текстом сервера', () async {
      client.handler = (_) => throw _backend(400, {'detail': 'Неверный код. Осталось попыток: 4'});

      await expectLater(
        repository.deleteAccount(code: '0000'),
        throwsA(
          isA<InvalidDeletionCodeException>().having(
            (e) => e.message,
            'message',
            'Неверный код. Осталось попыток: 4',
          ),
        ),
      );
    });

    test('прочие ошибки проходят как есть', () async {
      client.handler = (_) => throw _backend(500);

      await expectLater(repository.deleteAccount(code: '1234'), throwsA(isA<BackendException>()));
    });
  });

  group('обратная связь', () {
    test('добавляет версию приложения и данные телефона', () async {
      await repository.sendFeedback(
        FeedbackModel(
          topic: FeedbackTopic.idea,
          message: '  Нужна тёмная тема  ',
          screenshot: File('/tmp/shot.png'),
        ),
      );

      expect(client.last.method, 'POST');
      expect(client.last.path, '/feedback/');
      expect(client.last.fields, {
        'topic': 'idea',
        'message': 'Нужна тёмная тема',
        'app_version': '1.2.0',
        'build_number': '45',
        'platform': 'ios',
        'os_version': 'iOS 18.1',
        'device_model': 'iPhone15,2',
      });
      expect(client.last.files!.single.field, 'screenshot');
    });

    test('без скриншота файлов нет', () async {
      await repository.sendFeedback(
        const FeedbackModel(topic: FeedbackTopic.question, message: 'Как это работает?'),
      );

      expect(client.last.files, isEmpty);
    });

    test('429 превращается в FeedbackRateLimitException', () async {
      client.handler = (_) => throw _backend(429);

      await expectLater(
        repository.sendFeedback(
          const FeedbackModel(topic: FeedbackTopic.problem, message: 'Ошибка'),
        ),
        throwsA(isA<FeedbackRateLimitException>()),
      );
    });
  });

  test('тема обращения по имени параметра маршрута', () {
    expect(FeedbackTopic.fromName('idea'), FeedbackTopic.idea);
    expect(FeedbackTopic.fromName('question'), FeedbackTopic.question);
    expect(FeedbackTopic.fromName('что-то'), FeedbackTopic.problem);
    expect(FeedbackTopic.fromName(null), FeedbackTopic.problem);
  });
}
