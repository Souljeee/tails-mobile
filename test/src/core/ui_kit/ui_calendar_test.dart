import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  Future<double> heightOf(WidgetTester tester, DateTime month, {required bool fixed}) async {
    await tester.pumpWidget(
      uiTestApp(MonthCalendar(key: UniqueKey(), initialMonth: month, fixedWeekRows: fixed)),
    );

    return tester.getSize(find.byType(MonthCalendar)).height;
  }

  group('MonthCalendar', () {
    // Февраль 2027 начинается в понедельник и занимает 4 недели, август 2026 — 6 недель.
    final feb = DateTime(2027, 2);
    final aug = DateTime(2026, 8);

    testWidgets('по умолчанию высота зависит от числа недель', (tester) async {
      final short = await heightOf(tester, feb, fixed: false);
      final long = await heightOf(tester, aug, fixed: false);

      expect(long, greaterThan(short));
    });

    testWidgets('fixedWeekRows: высота одинакова во всех месяцах', (tester) async {
      final heights = <double>[
        for (var m = 1; m <= 12; m++)
          await heightOf(tester, DateTime(2026 + (m > 6 ? 1 : 0), m), fixed: true),
        await heightOf(tester, feb, fixed: true),
        await heightOf(tester, aug, fixed: true),
      ];

      expect(heights.toSet(), hasLength(1));
    });
  });
}
