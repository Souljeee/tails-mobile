import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_switcher/ui_switcher.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

class PetTypeSelection extends StatelessWidget {
  final void Function(PetTypeEnum type) onTypeChanged;

  const PetTypeSelection({
    required this.onTypeChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Кто это?',
          style: context.uiFonts.header20Medium,
        ),
        const SizedBox(height: 8),
        UiSwitcher<PetTypeEnum>(
          options: const [
            UiSwitcherOption(
              value: PetTypeEnum.cat,
              label: 'Кошка',
              icon: Icons.pets,
            ),
            UiSwitcherOption(
              value: PetTypeEnum.dog,
              label: 'Собака',
              icon: Icons.cruelty_free,
            ),
          ],
          onTypeChanged: onTypeChanged,
        ),
      ],
    );
  }
}
