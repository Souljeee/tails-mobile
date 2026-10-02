import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/pet_form_body.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_form_validation.dart';

import '../../../helpers/ui_test_app.dart';

void main() {
  testWidgets('PetFormBody показывает секции и передаёт выбор вида, пола и нажатия', (
    tester,
  ) async {
    PetTypeEnum? type;
    PetSexEnum? sex;
    var breedTaps = 0;
    var dateTaps = 0;
    bool? castration;

    await tester.pumpWidget(
      uiTestApp(
        PetFormBody(
          petType: PetTypeEnum.cat,
          gender: PetSexEnum.male,
          nameController: UiTextFieldController(),
          breedController: UiTextFieldController(),
          birthDateController: UiTextFieldController(),
          colorController: UiTextFieldController(),
          onImageSelected: (_) {},
          onTypeChanged: (value) => type = value,
          onSexChanged: (value) => sex = value,
          onBreedTap: () => breedTaps++,
          onBirthDateTap: () => dateTaps++,
          onWeightSelected: (_) {},
          onCastrationSelected: (value) => castration = value,
        ),
      ),
    );

    expect(find.text('ОСНОВНОЕ'), findsOneWidget);
    expect(find.text('ДЕТАЛИ'), findsOneWidget);
    expect(find.text('Кастрирован'), findsOneWidget);

    await tester.tap(find.text('Собака'));
    await tester.tap(find.text('Женский'));
    await tester.ensureVisible(find.text('Порода'));
    await tester.tap(find.text('Порода'));
    await tester.ensureVisible(find.text('Дата рождения'));
    await tester.tap(find.text('Дата рождения'));
    await tester.pump();

    expect(type, PetTypeEnum.dog);
    expect(sex, PetSexEnum.female);
    expect(breedTaps, 1);
    expect(dateTaps, 1);
    expect(castration, isNull);
  });

  testWidgets('PetFormBody показывает ошибки у незаполненных полей', (tester) async {
    await tester.pumpWidget(
      uiTestApp(
        PetFormBody(
          petType: PetTypeEnum.cat,
          gender: PetSexEnum.male,
          nameController: UiTextFieldController(),
          breedController: UiTextFieldController(),
          birthDateController: UiTextFieldController(),
          colorController: UiTextFieldController(),
          invalidFields: const {PetFormField.name, PetFormField.breed, PetFormField.weight},
          onImageSelected: (_) {},
          onTypeChanged: (_) {},
          onSexChanged: (_) {},
          onBreedTap: () {},
          onBirthDateTap: () {},
          onWeightSelected: (_) {},
          onCastrationSelected: (_) {},
        ),
      ),
    );

    expect(find.text('Введите кличку'), findsOneWidget);
    // Текст «Выберите породу» совпадает с подсказкой поля: подсказка + ошибка.
    expect(find.text('Выберите породу'), findsNWidgets(2));
    expect(find.text('Укажите вес'), findsOneWidget);
    expect(find.text('Введите окрас'), findsNothing);
    expect(find.text('Укажите дату рождения'), findsNothing);
  });
}
