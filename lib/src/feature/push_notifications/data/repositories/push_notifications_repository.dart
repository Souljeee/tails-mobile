import 'dart:async';

import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/logging/tails_logger.dart';
import 'package:tails_mobile/src/core/utils/background_error.dart';
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
  }) : _messaging = messagingDataSource,
       _localNotifications = localNotificationsDataSource,
       _devices = devicesRemoteDataSource;

  static const String _androidPlatform = 'android';
  static const String _logSource = 'PushNotificationsRepository';

  final PushMessagingDataSource _messaging;
  final LocalNotificationsDataSource _localNotifications;
  final DevicesRemoteDataSource _devices;

  final StreamController<PushNotification> _opened = StreamController.broadcast();
  final StreamController<PushNotification> _received = StreamController.broadcast();
  final StreamController<BackgroundError> _backgroundErrors = StreamController.broadcast();
  final List<StreamSubscription<Object?>> _subscriptions = [];

  Future<bool>? _initialization;
  bool _isAvailable = false;
  bool _initialMessageHandled = false;
  String? _registeredToken;

  /// Уведомления, которые пользователь открыл нажатием.
  Stream<PushNotification> get openedNotifications => _opened.stream;

  /// Уведомления, пришедшие, пока приложение открыто.
  Stream<PushNotification> get receivedNotifications => _received.stream;

  /// Ошибки фоновых операций (обновление токена, показ уведомления), которые некому
  /// пробросить вызывающему коду.
  Stream<BackgroundError> get backgroundErrors => _backgroundErrors.stream;

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
      TailsLogger.warning('FCM-токен пока недоступен', source: _logSource);

      return PushConnectionStatus.unavailable;
    }

    await _register(token);

    return permission == PushPermissionStatus.granted
        ? PushConnectionStatus.connected
        : PushConnectionStatus.permissionDenied;
  }

  /// Отвязывает устройство на сервере. Нужен действующий JWT, поэтому вызывается до выхода из
  /// аккаунта.
  ///
  /// Throws RestClientException, если сервер не принял запрос. `AuthRepository.logout`
  /// в этом случае всё равно завершает выход.
  Future<void> unregisterDevice() async {
    final token = _registeredToken;

    if (token == null) {
      return;
    }

    await _devices.unregister(token: token);
    _registeredToken = null;
  }

  /// Прекращает слушать уведомления и удаляет токен на устройстве: после выхода или удаления
  /// аккаунта следующий пользователь получит новый токен. Сеть не используется.
  ///
  /// Подписки отменяются в любом случае; ошибку удаления токена пробрасывает.
  Future<void> stop() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _registeredToken = null;

    if (!_isAvailable) {
      return;
    }

    await _messaging.deleteToken();
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
      // Вызывающего кода нет: токен зарегистрируется при следующем запуске.
      _backgroundErrors.add((error: e, stackTrace: s));
    }
  }

  void _onForegroundMessage(PushMessageDto message) {
    final payload = PushPayload.fromData(message.data);

    TailsAnalytics.log(
      TailsAnalyticsEvents.pushReceivedForeground(type: payload.type.analyticsName),
    );

    _received.add(PushNotification(title: message.title, body: message.body, payload: payload));

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
      _backgroundErrors.add((error: e, stackTrace: s));
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
