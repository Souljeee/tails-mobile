import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_switcher/ui_switcher.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';

class SexSection extends StatelessWidget {
  final void Function(PetSexEnum sex) onSexChanged;

  const SexSection({
    required this.onSexChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Пол',
          style: context.uiFonts.header20Medium,
        ),
        const SizedBox(height: 8),
        UiSwitcher<PetSexEnum>(
          options: const [
            UiSwitcherOption(value: PetSexEnum.male, label: 'Мужской', icon: Icons.male),
            UiSwitcherOption(value: PetSexEnum.female, label: 'Женский', icon: Icons.female),
          ],
          onTypeChanged: onSexChanged,
        ),
      ],
    );
  }
}