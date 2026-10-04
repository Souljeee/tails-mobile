import 'dart:async';

import 'package:tails_mobile/src/core/utils/logger/logger.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/devices_remote_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/dtos/push_message_dto.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/local_notifications_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/push_messaging_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/models/push_notification.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/models/push_payload.dart';

/// Итог подключения устройства к push-уведомлениям.
enum PushConnectionStatus {
  /// Разрешение есть, токен зарегистрирован на сервере.
  connected,

  /// Пользователь запретил уведомления в системе. Токен всё равно зарегистрирован,
  /// чтобы уведомления заработали сразу после включения в настройках телефона.
  permissionDenied,

  /// Firebase не настроен или токен получить не удалось.
  unavailable,
}

/// Push-уведомления: регистрация устройства на сервере, показ и открытие уведомлений.
class PushNotificationsRepository {
  PushNotificationsRepository({
    required PushMessagingDataSource messagingDataSource,
    required LocalNotificationsDataSource localNotificationsDataSource,
    required DevicesRemoteDataSource devicesRemoteDataSource,
    required Logger logger,
  }) : _messaging = messagingDataSource,
       _localNotifications = localNotificationsDataSource,
       _devices = devicesRemoteDataSource,
       _logger = logger;

  static const String _androidPlatform = 'android';

  final PushMessagingDataSource _messaging;
  final LocalNotificationsDataSource _localNotifications;
  final DevicesRemoteDataSource _devices;
  final Logger _logger;

  final StreamController<PushNotification> _opened = StreamController.broadcast();
  final List<StreamSubscription<Object?>> _subscriptions = [];

  Future<bool>? _initialization;
  bool _isAvailable = false;
  bool _initialMessageHandled = false;
  String? _registeredToken;

  /// Уведомления, которые пользователь открыл нажатием.
  Stream<PushNotification> get openedNotifications => _opened.stream;

  /// Запрашивает разрешение, регистрирует токен устройства на сервере и начинает слушать
  /// уведомления. Безопасно вызывать повторно.
  ///
  /// Throws RestClientException, если сервер не принял токен.
  Future<PushConnectionStatus> connectDevice() async {
    if (!await (_initialization ??= _initialize())) {
      return PushConnectionStatus.unavailable;
    }

    final permission = await _messaging.requestPermission();

    await _startListening();

    final token = await _messaging.getToken();

    if (token == null) {
      // Токен придёт через onTokenRefresh, когда появится APNs-токен.
      _logger.warn('FCM-токен пока недоступен');

      return PushConnectionStatus.unavailable;
    }

    await _register(token);

    return permission == PushPermissionStatus.granted
        ? PushConnectionStatus.connected
        : PushConnectionStatus.permissionDenied;
  }

  /// Отвязывает устройство на сервере. Нужен действующий JWT, поэтому вызывается до выхода из
  /// аккаунта. Ошибки не пробрасываются: выход не должен зависеть от push.
  Future<void> unregisterDevice() async {
    final token = _registeredToken;

    if (token == null) {
      return;
    }

    try {
      await _devices.unregister(token: token);
      _registeredToken = null;
    } on Object catch (e, s) {
      _logger.warn('Не удалось отвязать устройство от push-уведомлений', error: e, stackTrace: s);
    }
  }

  /// Прекращает слушать уведомления и удаляет токен на устройстве: после выхода или удаления
  /// аккаунта следующий пользователь получит новый токен. Сеть не используется.
  Future<void> stop() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _registeredToken = null;

    if (!_isAvailable) {
      return;
    }

    try {
      await _messaging.deleteToken();
    } on Object catch (e, s) {
      _logger.warn('Не удалось удалить FCM-токен устройства', error: e, stackTrace: s);
    }
  }

  Future<bool> _initialize() async {
    _isAvailable = await _messaging.initialize();

    if (_isAvailable) {
      await _localNotifications.initialize();
    }

    return _isAvailable;
  }

  Future<void> _startListening() async {
    if (_subscriptions.isEmpty) {
      _subscriptions
        ..add(_messaging.onTokenRefresh.listen(_onTokenRefreshed))
        ..add(_messaging.onMessage.listen(_onForegroundMessage))
        ..add(_messaging.onMessageOpenedApp.listen(_onMessageOpened))
        ..add(_localNotifications.onTap.listen(_onLocalNotificationTapped));
    }

    if (!_initialMessageHandled) {
      _initialMessageHandled = true;

      final initial = await _messaging.getInitialMessage();

      if (initial != null) {
        _onMessageOpened(initial);
      }
    }
  }

  Future<void> _register(String token) async {
    if (token == _registeredToken) {
      return;
    }

    await _devices.register(token: token, platform: _messaging.platform);

    _registeredToken = token;
  }

  Future<void> _onTokenRefreshed(String token) async {
    try {
      await _register(token);
    } on Object catch (e, s) {
      // Некому показать ошибку: токен зарегистрируется при следующем запуске.
      _logger.error('Не удалось зарегистрировать обновлённый FCM-токен', error: e, stackTrace: s);
    }
  }

  void _onForegroundMessage(PushMessageDto message) {
    // На iOS баннер в открытом приложении показывает система; на Android — только мы.
    if (_messaging.platform == _androidPlatform) {
      unawaited(_showLocally(message));
    }
  }

  Future<void> _showLocally(PushMessageDto message) async {
    try {
      await _localNotifications.show(
        id:
            Object.hash(message.messageId, message.data['event_id'], message.data['time']) &
            0x7fffffff,
        title: message.title,
        body: message.body,
        payload: message.data,
      );
    } on Object catch (e, s) {
      _logger.error('Не удалось показать уведомление', error: e, stackTrace: s);
    }
  }

  void _onMessageOpened(PushMessageDto message) => _opened.add(
    PushNotification(
      title: message.title,
      body: message.body,
      payload: PushPayload.fromData(message.data),
    ),
  );

  void _onLocalNotificationTapped(Map<String, String> data) =>
      _opened.add(PushNotification(payload: PushPayload.fromData(data)));
}
