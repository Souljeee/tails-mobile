import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/utils/event_time_converter.dart';

void main() {
  group('EventTimeConverter', () {
    test('локальное время Москвы переводится в UTC и обратно', () {
      expect(EventTimeConverter.localToUtc('17:05', offsetMinutes: 180), '14:05');
      expect(EventTimeConverter.utcToLocal('14:05:00', offsetMinutes: 180), '17:05');
    });

    test('переход через полночь в обе стороны', () {
      expect(EventTimeConverter.localToUtc('01:00', offsetMinutes: 180), '22:00');
      expect(EventTimeConverter.utcToLocal('22:00', offsetMinutes: 180), '01:00');
      expect(EventTimeConverter.localToUtc('23:30', offsetMinutes: -300), '04:30');
      expect(EventTimeConverter.utcToLocal('04:30', offsetMinutes: -300), '23:30');
    });

    test('дробные и крайние смещения', () {
      expect(EventTimeConverter.localToUtc('17:05', offsetMinutes: 330), '11:35');
      expect(EventTimeConverter.localToUtc('00:00', offsetMinutes: 840), '10:00');
      expect(EventTimeConverter.localToUtc('00:00', offsetMinutes: -840), '14:00');
    });

    test('туда и обратно возвращает исходное время при любом смещении', () {
      for (final offset in [-840, -300, 0, 180, 330, 840]) {
        final utc = EventTimeConverter.localToUtc('01:00', offsetMinutes: offset);
        expect(EventTimeConverter.utcToLocal(utc, offsetMinutes: offset), '01:00');
      }
    });

    test('пустое и некорректное время даёт null', () {
      expect(EventTimeConverter.localToUtc(null, offsetMinutes: 180), isNull);
      expect(EventTimeConverter.localToUtc('', offsetMinutes: 180), isNull);
      expect(EventTimeConverter.utcToLocal('xx:yy', offsetMinutes: 180), isNull);
      expect(EventTimeConverter.utcToLocal('25:00', offsetMinutes: 180), isNull);
    });

    test('смещение устройства берётся на дату события', () {
      final offset = EventTimeConverter.deviceOffsetMinutes(DateTime(2026, 10, 5), time: '17:05');
      expect(offset, DateTime(2026, 10, 5, 17, 5).timeZoneOffset.inMinutes);
    });
  });
}
