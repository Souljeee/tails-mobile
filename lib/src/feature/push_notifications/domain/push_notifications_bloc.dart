import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rest_client/rest_client.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/models/push_notification.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/push_notifications_repository.dart';

part 'push_notifications_event.dart';
part 'push_notifications_state.dart';

/// Подключает устройство к push-уведомлениям, пока пользователь авторизован,
/// и сообщает о нажатиях на уведомления.
class PushNotificationsBloc extends Bloc<PushNotificationsEvent, PushNotificationsState> {
  PushNotificationsBloc({
    required PushNotificationsRepository repository,
    required AuthorizationStatus initialAuthorizationStatus,
    required Stream<AuthorizationStatus> authorizationStatus,
  }) : _repository = repository,
       super(const PushNotificationsState()) {
    on<PushNotificationsEvent>(
      (event, emit) => event.map(
        authorizationChanged: (event) => _onAuthorizationChanged(event, emit),
        notificationOpened: (event) => _onNotificationOpened(event, emit),
      ),
    );

    _subscriptions
      ..add(
        authorizationStatus.listen(
          (status) => add(PushNotificationsEvent.authorizationChanged(status: status)),
        ),
      )
      ..add(
        repository.openedNotifications.listen(
          (notification) =>
              add(PushNotificationsEvent.notificationOpened(notification: notification)),
        ),
      );

    add(PushNotificationsEvent.authorizationChanged(status: initialAuthorizationStatus));
  }

  final PushNotificationsRepository _repository;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  Future<void> _onAuthorizationChanged(
    PushNotificationsEvent$AuthorizationChanged event,
    Emitter<PushNotificationsState> emit,
  ) async {
    if (event.status != AuthorizationStatus.authorized) {
      await _repository.stop();

      emit(state.copyWith(status: PushNotificationsStatus.idle));

      return;
    }

    try {
      emit(state.copyWith(status: PushNotificationsStatus.connecting));

      final connection = await _repository.connectDevice();

      emit(state.copyWith(status: _statusOf(connection)));
    } catch (e, s) {
      addError(e, s);

      emit(state.copyWith(status: PushNotificationsStatus.failure));
    }
  }

  Future<void> _onNotificationOpened(
    PushNotificationsEvent$NotificationOpened event,
    Emitter<PushNotificationsState> emit,
  ) async {
    emit(state.copyWith(lastOpened: event.notification, openedCount: state.openedCount + 1));
  }

  PushNotificationsStatus _statusOf(PushConnectionStatus connection) => switch (connection) {
    PushConnectionStatus.connected => PushNotificationsStatus.connected,
    PushConnectionStatus.permissionDenied => PushNotificationsStatus.permissionDenied,
    PushConnectionStatus.unavailable => PushNotificationsStatus.unavailable,
  };

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }

    return super.close();
  }
}
