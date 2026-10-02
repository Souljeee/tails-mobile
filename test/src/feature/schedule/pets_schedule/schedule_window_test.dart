import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/domain/schedule_window.dart';

void main() {
  group('ScheduleWindow', () {
    test('строится на 180 дней в обе стороны от даты без учёта времени', () {
      final window = ScheduleWindow.around(DateTime(2026, 9, 29, 23, 30));

      expect(window.start, DateTime(2026, 9, 29).subtract(const Duration(days: 180)));
      expect(window.end, DateTime(2026, 9, 29).add(const Duration(days: 180)));
    });

    test('coversMonth: месяц внутри окна покрыт', () {
      final window = ScheduleWindow.around(DateTime(2026, 9, 29));

      expect(window.coversMonth(DateTime(2026, 9)), isTrue);
      expect(window.coversMonth(DateTime(2027)), isTrue);
      expect(window.coversMonth(DateTime(2026, 5)), isTrue);
    });

    test('coversMonth: месяц, выходящий за границы окна, не покрыт', () {
      final window = ScheduleWindow.around(DateTime(2026, 9, 29));

      // Окно заканчивается 28.03.2027, поэтому март 2027 покрыт не целиком.
      expect(window.coversMonth(DateTime(2027, 3)), isFalse);
      expect(window.coversMonth(DateTime(2027, 6)), isFalse);
      expect(window.coversMonth(DateTime(2025, 12)), isFalse);
    });

    test('после сдвига окна месяц, к которому листали, покрыт', () {
      final shifted = ScheduleWindow.around(DateTime(2027, 6));

      expect(shifted.coversMonth(DateTime(2027, 6)), isTrue);
    });
  });
}
