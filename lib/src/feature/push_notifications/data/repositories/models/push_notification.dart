import 'package:equatable/equatable.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/models/push_payload.dart';

/// Уведомление, которое получил или открыл пользователь.
class PushNotification extends Equatable {
  const PushNotification({this.title, this.body, this.payload = const PushPayload()});

  final String? title;
  final String? body;
  final PushPayload payload;

  @override
  List<Object?> get props => [title, body, payload];
}
