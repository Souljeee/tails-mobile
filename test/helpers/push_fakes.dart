import 'dart:async';

import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/dtos/push_message_dto.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/local_notifications_data_source.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/data_sources/push_messaging_data_source.dart';

/// Подставной [PushMessagingDataSource]: события отправляются вручную через контроллеры.
class FakePushMessagingDataSource implements PushMessagingDataSource {
  FakePushMessagingDataSource({this.platform = 'android'});

  @override
  String? platform;

  bool isConfigured = true;
  PushPermissionStatus permission = PushPermissionStatus.granted;
  String? token = 'token-1';
  PushMessageDto? initialMessage;

  /// Если задан, [deleteToken] завершается этой ошибкой.
  Object? deleteTokenError;

  int initializeCalls = 0;
  int requestPermissionCalls = 0;
  int deleteTokenCalls = 0;
  int getInitialMessageCalls = 0;

  final tokenRefresh = StreamController<String>.broadcast();
  final messages = StreamController<PushMessageDto>.broadcast();
  final opened = StreamController<PushMessageDto>.broadcast();

  @override
  Future<bool> initialize() async {
    initializeCalls++;

    return isConfigured;
  }

  @override
  Future<PushPermissionStatus> requestPermission() async {
    requestPermissionCalls++;

    return permission;
  }

  @override
  Future<String?> getToken() async => token;

  @override
  Future<void> deleteToken() async {
    deleteTokenCalls++;

    if (deleteTokenError != null) {
      // ignore: only_throw_errors
      throw deleteTokenError!;
    }
  }

  @override
  Stream<String> get onTokenRefresh => tokenRefresh.stream;

  @override
  Stream<PushMessageDto> get onMessage => messages.stream;

  @override
  Stream<PushMessageDto> get onMessageOpenedApp => opened.stream;

  @override
  Future<PushMessageDto?> getInitialMessage() async {
    getInitialMessageCalls++;

    return initialMessage;
  }

  Future<void> dispose() async {
    await tokenRefresh.close();
    await messages.close();
    await opened.close();
  }
}

/// Показанное локальное уведомление.
typedef ShownNotification = ({int id, String? title, String? body, Map<String, String> payload});

class FakeLocalNotificationsDataSource implements LocalNotificationsDataSource {
  int initializeCalls = 0;
  final List<ShownNotification> shown = [];
  final taps = StreamController<Map<String, String>>.broadcast();

  /// Если задан, [show] завершается этой ошибкой.
  Object? showError;

  @override
  Future<void> initialize() async => initializeCalls++;

  @override
  Future<void> show({
    required int id,
    required String? title,
    required String? body,
    required Map<String, String> payload,
  }) async {
    if (showError != null) {
      // ignore: only_throw_errors
      throw showError!;
    }

    shown.add((id: id, title: title, body: body, payload: payload));
  }

  @override
  Stream<Map<String, String>> get onTap => taps.stream;

  Future<void> dispose() => taps.close();
}
