import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_selectable_card/ui_selectable_card.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';

/// Выбор пола питомца: две карточки-радио.
class SexSection extends StatelessWidget {
  final PetSexEnum? value;
  final void Function(PetSexEnum sex) onSexChanged;

  const SexSection({required this.value, required this.onSexChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: UiSelectableCard(
            label: l10n.petSexMale,
            selected: value == PetSexEnum.male,
            icon: Icons.male,
            onTap: () => onSexChanged(PetSexEnum.male),
          ),
        ),
        const SizedBox(width: UiSpacing.x3),
        Expanded(
          child: UiSelectableCard(
            label: l10n.petSexFemale,
            selected: value == PetSexEnum.female,
            icon: Icons.female,
            onTap: () => onSexChanged(PetSexEnum.female),
          ),
        ),
      ],
    );
  }
}
