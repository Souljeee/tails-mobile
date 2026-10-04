import 'package:equatable/equatable.dart';

/// Вид уведомления о событии (поле `type` в данных пуша).
enum PushNotificationType {
  /// В момент времени события.
  standard,

  /// Накануне вечером для события без времени.
  reminder,

  /// Утром в день события без времени.
  finalReminder,

  unknown;

  static PushNotificationType fromWire(String? value) => switch (value) {
    'standard' => standard,
    'reminder' => reminder,
    'final' => finalReminder,
    _ => unknown,
  };
}

/// Данные пуша о событии: по ним открывается нужное место в приложении.
class PushPayload extends Equatable {
  const PushPayload({this.eventId, this.type = PushNotificationType.unknown, this.date, this.time});

  /// Разбирает данные FCM; отсутствующие или некорректные поля становятся `null`.
  factory PushPayload.fromData(Map<String, String> data) => PushPayload(
    eventId: int.tryParse(data['event_id'] ?? ''),
    type: PushNotificationType.fromWire(data['type']),
    date: DateTime.tryParse(data['date'] ?? ''),
    time: data['time'],
  );

  final int? eventId;
  final PushNotificationType type;

  /// Дата вхождения события.
  final DateTime? date;

  /// Время слота `HH:MM`, если у события несколько времён в день.
  final String? time;

  @override
  List<Object?> get props => [eventId, type, date, time];
}
