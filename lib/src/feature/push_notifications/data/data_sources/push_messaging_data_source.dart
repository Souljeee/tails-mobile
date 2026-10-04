import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tails_mobile/src/core/utils/logger/logger.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/dtos/push_message_dto.dart';

/// Состояние системного разрешения на уведомления.
enum PushPermissionStatus { granted, denied }

/// Доступ к Firebase Cloud Messaging. Весь SDK Firebase используется только здесь.
abstract interface class PushMessagingDataSource {
  /// Платформа устройства для сервера: `ios` или `android`, `null` для остальных.
  String? get platform;

  /// Инициализирует Firebase. `false`, если Firebase не настроен (нет файлов конфигурации).
  Future<bool> initialize();

  /// Запрашивает разрешение, если оно ещё не выдано.
  Future<PushPermissionStatus> requestPermission();

  /// Токен устройства; `null`, если его пока нельзя получить (например, нет APNs-токена).
  Future<String?> getToken();

  Future<void> deleteToken();

  Stream<String> get onTokenRefresh;

  /// Сообщения, пришедшие, пока приложение открыто.
  Stream<PushMessageDto> get onMessage;

  /// Нажатия на уведомление, пока приложение работало в фоне.
  Stream<PushMessageDto> get onMessageOpenedApp;

  /// Уведомление, нажатием на которое запустили закрытое приложение.
  Future<PushMessageDto?> getInitialMessage();
}

final class FirebasePushMessagingDataSource implements PushMessagingDataSource {
  FirebasePushMessagingDataSource({required Logger logger}) : _logger = logger;

  /// На iOS FCM-токен доступен только после получения APNs-токена, который приходит не сразу.
  static const int _apnsTokenAttempts = 5;
  static const Duration _apnsTokenDelay = Duration(seconds: 1);

  final Logger _logger;

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  @override
  String? get platform {
    if (Platform.isIOS) {
      return 'ios';
    }

    if (Platform.isAndroid) {
      return 'android';
    }

    return null;
  }

  @override
  Future<bool> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // На iOS без этого баннер в открытом приложении не показывается.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      return true;
    } on Object catch (e, s) {
      // Без GoogleService-Info.plist / google-services.json Firebase не стартует;
      // приложение должно работать и без push.
      _logger.warn('Firebase не настроен, push-уведомления отключены', error: e, stackTrace: s);

      return false;
    }
  }

  @override
  Future<PushPermissionStatus> requestPermission() async {
    var status = (await _messaging.getNotificationSettings()).authorizationStatus;

    if (!_isGranted(status)) {
      status = (await _messaging.requestPermission()).authorizationStatus;
    }

    return _isGranted(status) ? PushPermissionStatus.granted : PushPermissionStatus.denied;
  }

  @override
  Future<String?> getToken() async {
    if (Platform.isIOS && !await _waitForApnsToken()) {
      return null;
    }

    return _messaging.getToken();
  }

  @override
  Future<void> deleteToken() => _messaging.deleteToken();

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<PushMessageDto> get onMessage => FirebaseMessaging.onMessage.map(_toDto);

  @override
  Stream<PushMessageDto> get onMessageOpenedApp => FirebaseMessaging.onMessageOpenedApp.map(_toDto);

  @override
  Future<PushMessageDto?> getInitialMessage() async {
    final message = await _messaging.getInitialMessage();

    return message == null ? null : _toDto(message);
  }

  Future<bool> _waitForApnsToken() async {
    for (var attempt = 0; attempt < _apnsTokenAttempts; attempt++) {
      if (await _messaging.getAPNSToken() != null) {
        return true;
      }

      await Future<void>.delayed(_apnsTokenDelay);
    }

    return false;
  }

  bool _isGranted(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized || status == AuthorizationStatus.provisional;

  PushMessageDto _toDto(RemoteMessage message) => PushMessageDto(
    messageId: message.messageId,
    title: message.notification?.title,
    body: message.notification?.body,
    data: message.data.map((key, value) => MapEntry(key, '$value')),
  );
}
