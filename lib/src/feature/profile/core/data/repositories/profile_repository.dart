import 'dart:async';
import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/device_info_data_source.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/notification_permission_data_source.dart';
import 'package:tails_mobile/src/feature/profile/core/data/data_sources/profile_remote_data_source.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/feedback_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/notification_settings_model.dart';
import 'package:tails_mobile/src/feature/profile/core/data/repositories/models/profile_model.dart';
import 'package:tails_mobile/src/feature/profile/core/enums/notification_category.dart';

/// Что изменилось в профиле; по этому событию экраны перечитывают данные.
enum ProfileRepositoryEvent { profileUpdated, notificationSettingsUpdated }

class ProfileRepository {
  ProfileRepository({
    required ProfileRemoteDataSource remoteDataSource,
    required DeviceInfoDataSource deviceInfoDataSource,
    required NotificationPermissionDataSource notificationPermissionDataSource,
    required PackageInfo packageInfo,
  }) : _remoteDataSource = remoteDataSource,
       _deviceInfoDataSource = deviceInfoDataSource,
       _notificationPermissionDataSource = notificationPermissionDataSource,
       _packageInfo = packageInfo;

  final ProfileRemoteDataSource _remoteDataSource;
  final DeviceInfoDataSource _deviceInfoDataSource;
  final NotificationPermissionDataSource _notificationPermissionDataSource;
  final PackageInfo _packageInfo;

  final _eventStreamController = StreamController<ProfileRepositoryEvent>.broadcast();

  Stream<ProfileRepositoryEvent> get eventStream => _eventStreamController.stream;

  Future<ProfileModel> getProfile() async =>
      ProfileModel.fromDto(await _remoteDataSource.getProfile());

  /// Сохраняет имя и фото. [name] `null` — не менять, пустая строка — очистить.
  Future<ProfileModel> updateProfile({String? name, File? avatar}) async {
    final dto = await _remoteDataSource.updateProfile(name: name, avatarPath: avatar?.path);

    _eventStreamController.add(ProfileRepositoryEvent.profileUpdated);

    return ProfileModel.fromDto(dto);
  }

  Future<void> deleteAvatar() async {
    await _remoteDataSource.deleteAvatar();

    _eventStreamController.add(ProfileRepositoryEvent.profileUpdated);
  }

  Future<NotificationSettingsModel> getNotificationSettings() async =>
      NotificationSettingsModel.fromDto(await _remoteDataSource.getNotificationSettings());

  /// Меняет одну категорию и возвращает состояние, подтверждённое сервером.
  Future<NotificationSettingsModel> setNotificationEnabled({
    required NotificationCategory category,
    required bool enabled,
  }) async {
    final dto = await _remoteDataSource.updateNotificationSetting(
      category: category,
      enabled: enabled,
    );

    _eventStreamController.add(ProfileRepositoryEvent.notificationSettingsUpdated);

    return NotificationSettingsModel.fromDto(dto);
  }

  Future<bool> isNotificationBlockedBySystem() =>
      _notificationPermissionDataSource.isBlockedBySystem();

  Future<void> openSystemSettings() => _notificationPermissionDataSource.openSettings();

  /// Отправляет код для удаления аккаунта; возвращает секунды до повторной отправки.
  ///
  /// Throws DeletionCodeTooSoonException.
  Future<int> sendDeletionCode() async =>
      (await _remoteDataSource.sendDeletionCode()).resendTimeoutSeconds;

  /// Удаляет аккаунт по коду из звонка. Локальные токены очищает вызывающий (`AuthRepository`).
  ///
  /// Throws InvalidDeletionCodeException.
  Future<void> deleteAccount({required String code}) => _remoteDataSource.deleteAccount(code: code);

  /// Отправляет обращение, добавляя версию приложения и данные телефона.
  ///
  /// Throws FeedbackRateLimitException.
  Future<void> sendFeedback(FeedbackModel feedback) async {
    final device = await _deviceInfoDataSource.load();

    await _remoteDataSource.sendFeedback(
      fields: {
        'topic': feedback.topic.apiValue,
        'message': feedback.message.trim(),
        'app_version': _packageInfo.version,
        'build_number': _packageInfo.buildNumber,
        'platform': device.platform,
        'os_version': device.osVersion,
        'device_model': device.deviceModel,
      },
      screenshotPath: feedback.screenshot?.path,
    );
  }

  Future<void> dispose() => _eventStreamController.close();
}
