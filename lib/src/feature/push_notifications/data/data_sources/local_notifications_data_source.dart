import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Локальные уведомления: на Android FCM сам не показывает пуш, пока приложение открыто.
///
/// Реализация работает только на Android. На iOS баннер в открытом приложении показывает
/// система, а инициализация плагина перехватила бы делегат уведомлений у Firebase.
abstract interface class LocalNotificationsDataSource {
  Future<void> initialize();

  Future<void> show({
    required int id,
    required String? title,
    required String? body,
    required Map<String, String> payload,
  });

  /// Нажатия на показанные уведомления; в событии — данные, переданные в [show].
  Stream<Map<String, String>> get onTap;
}

final class FlutterLocalNotificationsDataSource implements LocalNotificationsDataSource {
  FlutterLocalNotificationsDataSource({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Совпадает с `com.google.firebase.messaging.default_notification_channel_id`
  /// в AndroidManifest: фоновые пуши используют тот же канал.
  static const String channelId = 'event_reminders';

  // Название видно в системных настройках Android. Создаётся до появления BuildContext,
  // поэтому не берётся из ARB; приложение пока только на русском.
  static const String _channelName = 'Напоминания о событиях';
  static const String _channelDescription = 'Напоминания о приёме пищи, прогулках и визитах';

  static const String _androidIcon = '@mipmap/ic_launcher';

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<Map<String, String>> _taps = StreamController.broadcast();

  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  Stream<Map<String, String>> get onTap => _taps.stream;

  @override
  Future<void> initialize() async {
    if (!_isAndroid) {
      return;
    }

    await _plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings(_androidIcon)),
      onDidReceiveNotificationResponse: _onResponse,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.high,
          ),
        );
  }

  @override
  Future<void> show({
    required int id,
    required String? title,
    required String? body,
    required Map<String, String> payload,
  }) async {
    if (!_isAndroid) {
      return;
    }

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(payload),
    );
  }

  void _onResponse(NotificationResponse response) {
    final raw = response.payload;

    if (raw == null || raw.isEmpty) {
      return;
    }

    final decoded = jsonDecode(raw);

    if (decoded is Map<String, dynamic>) {
      _taps.add(decoded.map((key, value) => MapEntry(key, '$value')));
    }
  }
}
