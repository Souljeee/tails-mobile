import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/models/push_payload.dart';

void main() {
  group('PushPayload.fromData', () {
    test('разбирает данные пуша о событии', () {
      final payload = PushPayload.fromData(const {
        'notification_id': 'n-1',
        'event_id': 'b3e0c2d4-6a53-4d0f-9d4c-2b3f5f0c7a11',
        'pet_id': '4',
        'event_type': 'dailyPills',
        'type': 'reminder',
        'date': '2026-10-05',
        'time': '08:00',
      });

      expect(payload.notificationId, 'n-1');
      expect(payload.eventId, 'b3e0c2d4-6a53-4d0f-9d4c-2b3f5f0c7a11');
      expect(payload.petId, 4);
      expect(payload.eventType, 'dailyPills');
      expect(payload.type, PushNotificationType.reminder);
      expect(payload.date, DateTime(2026, 10, 5));
      expect(payload.time, '08:00');
    });

    test('различает все виды уведомлений', () {
      expect(PushNotificationType.fromWire('standard'), PushNotificationType.standard);
      expect(PushNotificationType.fromWire('final'), PushNotificationType.finalReminder);
      expect(PushNotificationType.fromWire('что-то новое'), PushNotificationType.unknown);
      expect(PushNotificationType.fromWire(null), PushNotificationType.unknown);
    });

    test('пустые и некорректные поля становятся null', () {
      final payload = PushPayload.fromData(const {
        'event_id': '',
        'notification_id': '',
        'pet_id': 'abc',
        'date': 'вчера',
      });

      expect(payload.eventId, isNull);
      expect(payload.notificationId, isNull);
      expect(payload.petId, isNull);
      expect(payload.date, isNull);
      expect(payload.time, isNull);
      expect(payload.type, PushNotificationType.unknown);
    });
  });
}
