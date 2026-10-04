import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/push_notifications/data/repositories/models/push_payload.dart';

void main() {
  group('PushPayload.fromData', () {
    test('разбирает данные пуша о событии', () {
      final payload = PushPayload.fromData(const {
        'event_id': '15',
        'type': 'reminder',
        'date': '2026-10-05',
        'time': '08:00',
      });

      expect(payload.eventId, 15);
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
      final payload = PushPayload.fromData(const {'event_id': 'abc', 'date': 'вчера'});

      expect(payload.eventId, isNull);
      expect(payload.date, isNull);
      expect(payload.time, isNull);
      expect(payload.type, PushNotificationType.unknown);
    });
  });
}
