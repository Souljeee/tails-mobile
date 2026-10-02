import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/navigation/shell_actions.dart';

void main() {
  group('ShellActionsController: фильтр календаря', () {
    test('просьба хранится, пока её не заберут, и забирается один раз', () {
      final controller = ShellActionsController();

      expect(controller.takeScheduleFilterRequest(), isNull);

      controller.requestScheduleFilter(7);

      expect(controller.takeScheduleFilterRequest()?.petId, 7);
      expect(controller.takeScheduleFilterRequest(), isNull);
    });

    test('слушатель получает просьбу и может её забрать', () {
      final controller = ShellActionsController();
      int? received;

      controller.scheduleFilterRequest.addListener(() {
        received = controller.takeScheduleFilterRequest()?.petId ?? received;
      });

      controller.requestScheduleFilter(3);

      expect(received, 3);
      expect(controller.scheduleFilterRequest.value, isNull);
    });

    test('новая просьба заменяет предыдущую', () {
      final controller = ShellActionsController()
        ..requestScheduleFilter(1)
        ..requestScheduleFilter(2);

      expect(controller.takeScheduleFilterRequest()?.petId, 2);
    });
  });
}
