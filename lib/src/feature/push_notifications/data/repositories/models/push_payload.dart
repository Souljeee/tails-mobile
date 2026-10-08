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

  /// Значение параметра `type` в событиях аналитики.
  String get analyticsName => switch (this) {
    standard => 'standard',
    reminder => 'reminder',
    finalReminder => 'final',
    unknown => 'unknown',
  };

  static PushNotificationType fromWire(String? value) => switch (value) {
    'standard' => standard,
    'reminder' => reminder,
    'final' => finalReminder,
    _ => unknown,
  };
}

/// Данные пуша о событии: по ним открывается нужное место в приложении.
class PushPayload extends Equatable {
  const PushPayload({
    this.notificationId,
    this.eventId,
    this.petId,
    this.eventType,
    this.type = PushNotificationType.unknown,
    this.date,
    this.time,
  });

  /// Разбирает данные FCM; отсутствующие или некорректные поля становятся `null`.
  factory PushPayload.fromData(Map<String, String> data) => PushPayload(
    notificationId: _nonEmpty(data['notification_id']),
    eventId: _nonEmpty(data['event_id']),
    petId: int.tryParse(data['pet_id'] ?? ''),
    eventType: _nonEmpty(data['event_type']),
    type: PushNotificationType.fromWire(data['type']),
    date: DateTime.tryParse(data['date'] ?? ''),
    time: data['time'],
  );

  /// Запись в центре уведомлений; по ней уведомление отмечается прочитанным.
  final String? notificationId;

  /// Идентификатор события (UUID).
  final String? eventId;
  final int? petId;

  /// Тип события (`ScheduleEventTypeEnum.name`).
  final String? eventType;
  final PushNotificationType type;

  /// Дата вхождения события.
  final DateTime? date;

  /// Время слота `HH:MM` (UTC), если у события несколько времён в день.
  final String? time;

  static String? _nonEmpty(String? value) => value == null || value.isEmpty ? null : value;

  @override
  List<Object?> get props => [notificationId, eventId, petId, eventType, type, date, time];
}
