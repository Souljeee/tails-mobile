import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_validators.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  group('UiTextField', () {
    testWidgets('показывает подпись, подсказку и placeholder', (tester) async {
      await tester.pumpWidget(
        uiTestApp(
          UiTextField(
            controller: UiTextFieldController(),
            labelText: 'Дата рождения',
            helperText: 'Не знаете точно — укажите примерную дату',
            placeholderText: 'ДД.ММ.ГГГГ',
          ),
        ),
      );

      expect(find.text('Дата рождения'), findsOneWidget);
      expect(find.text('Не знаете точно — укажите примерную дату'), findsOneWidget);
      expect(find.text('ДД.ММ.ГГГГ'), findsOneWidget);
    });

    testWidgets('показывает дополнительный текст справа', (tester) async {
      await tester.pumpWidget(
        uiTestApp(UiTextField(controller: UiTextFieldController(), secondaryText: 'кг')),
      );

      expect(find.text('кг'), findsOneWidget);
    });

    testWidgets('передаёт введённый текст в onChanged и контроллер', (tester) async {
      final controller = UiTextFieldController();
      String? changed;

      await tester.pumpWidget(
        uiTestApp(UiTextField(controller: controller, onChanged: (value) => changed = value)),
      );
      await tester.enterText(find.byType(TextField), 'Мурка');

      expect(changed, 'Мурка');
      expect(controller.text, 'Мурка');
    });

    testWidgets('показывает ошибку валидации после взаимодействия с полем', (tester) async {
      final controller = UiTextFieldController(
        validators: const [RequiredFieldValidator(validationMessage: 'Обязательное поле')],
      );

      await tester.pumpWidget(uiTestApp(UiTextField(controller: controller)));

      expect(find.text('Обязательное поле'), findsNothing);

      await tester.enterText(find.byType(TextField), 'а');
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(find.text('Обязательное поле'), findsOneWidget);
    });
  });
}
