import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_avatar/ui_pet_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';

typedef OnSelectedPetsChanged = void Function(int? selectedPetId);

/// Горизонтальный список чипов «Все» + питомцы для фильтрации расписания.
///
/// Выбранный питомец хранит родитель ([selectedPetId]), поэтому выбор не теряется,
/// когда список перезагружается.
class PetsChipList extends StatelessWidget {
  static const double _avatarSize = 24;

  final List<PetModel> pets;

  /// `null` — выбрано «Все».
  final int? selectedPetId;
  final OnSelectedPetsChanged onSelectedPetsChanged;

  const PetsChipList({
    required this.pets,
    required this.selectedPetId,
    required this.onSelectedPetsChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return SizedBox(
      height: UiChip.height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
        itemCount: pets.length + 1,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: UiSpacing.x2),
        itemBuilder: (context, index) {
          if (index == 0) {
            final selected = selectedPetId == null;

            return UiChip(
              label: context.l10n.all,
              selected: selected,
              onTap: () => onSelectedPetsChanged(null),
              leading: Icon(Icons.pets, size: 18, color: selected ? palette.surface : palette.ink2),
            );
          }

          final pet = pets[index - 1];

          return UiChip(
            label: pet.name,
            selected: selectedPetId == pet.id,
            onTap: () => onSelectedPetsChanged(pet.id),
            leading: UiPetAvatar(imageUrl: pet.image, size: _avatarSize),
          );
        },
      ),
    );
  }
}
