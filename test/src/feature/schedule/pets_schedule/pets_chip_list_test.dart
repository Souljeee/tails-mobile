import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/pets_schedule/presentation/widgets/pets_chip_list.dart';

import '../../../../helpers/ui_test_app.dart';

PetModel _pet(int id, String name) => PetModel(
  id: id,
  petType: PetTypeEnum.dog,
  name: name,
  breed: const BreedModel(id: 1, name: 'Корги'),
  gender: 'M',
  birthday: DateTime(2020),
  color: 'рыжий',
  image: '',
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  testWidgets('PetsChipList отражает выбор родителя и сообщает о тапе', (tester) async {
    int? tapped = -1;
    final pets = [_pet(1, 'Рекс'), _pet(2, 'Бобик')];

    await tester.pumpWidget(
      uiTestApp(
        PetsChipList(pets: pets, selectedPetId: 2, onSelectedPetsChanged: (id) => tapped = id),
      ),
    );

    final chips = tester.widgetList<UiChip>(find.byType(UiChip)).toList();

    expect(chips.map((chip) => chip.selected), [false, false, true]);

    await tester.tap(find.text('Рекс'));
    expect(tapped, 1);
  });
}
