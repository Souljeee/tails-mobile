import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/app_theme_data.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: UiThemeData.lightTheme,
  home: Scaffold(body: child),
);

void main() {
  group('UiButton', () {
    testWidgets('вызывает onPressed по нажатию', (tester) async {
      var pressed = 0;

      await tester.pumpWidget(
        _wrap(UiButton.main(label: 'Получить код', onPressed: () => pressed++)),
      );
      await tester.tap(find.text('Получить код'));

      expect(pressed, 1);
    });

    testWidgets('не реагирует на нажатие без onPressed', (tester) async {
      await tester.pumpWidget(_wrap(const UiButton.main(label: 'Получить код')));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      expect(button.onPressed, isNull);
    });

    testWidgets('во время загрузки показывает индикатор и блокирует нажатие', (tester) async {
      var pressed = 0;

      await tester.pumpWidget(
        _wrap(UiButton.main(label: 'Получить код', isLoading: true, onPressed: () => pressed++)),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Получить код'), findsNothing);

      await tester.tap(find.byType(ElevatedButton));

      expect(pressed, 0);
    });

    testWidgets('высота: 56 по умолчанию и 44 для размера m', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              UiButton.main(label: 'Крупная', onPressed: () {}),
              UiButton.main(label: 'Средняя', size: UiButtonSize.m, onPressed: () {}),
            ],
          ),
        ),
      );

      expect(tester.getSize(find.widgetWithText(ElevatedButton, 'Крупная')).height, 56);
      expect(tester.getSize(find.widgetWithText(ElevatedButton, 'Средняя')).height, 44);
    });
  });
}
