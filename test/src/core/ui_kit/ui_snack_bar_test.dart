import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  testWidgets('снекбар с действием: кнопка вызывает onAction и закрывает снекбар', (tester) async {
    var undone = 0;
    SnackBarClosedReason? reason;

    await tester.pumpWidget(
      uiTestApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showUiSnackBar(
              context,
              message: 'Событие отменено',
              kind: UiSnackBarKind.info,
              actionLabel: 'Вернуть',
              duration: const Duration(seconds: 6),
              onAction: () => undone++,
            ).closed.then((value) => reason = value),
            child: const Text('show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Событие отменено'), findsOneWidget);

    await tester.tap(find.text('Вернуть'));
    await tester.pumpAndSettle();

    expect(undone, 1);
    expect(reason, SnackBarClosedReason.action);
  });

  testWidgets('без действия кнопки нет', (tester) async {
    await tester.pumpWidget(
      uiTestApp(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => showUiSnackBar(context, message: 'Ошибка'),
            child: const Text('show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(SnackBarAction), findsNothing);
  });
}
