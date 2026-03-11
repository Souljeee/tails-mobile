import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';

typedef OnSelectedPetsChanged = void Function(int? selectedPetId);

class PetsChipList extends StatefulWidget {
  final List<PetModel> pets;
  final OnSelectedPetsChanged onSelectedPetsChanged;

  const PetsChipList({required this.pets, required this.onSelectedPetsChanged, super.key});

  @override
  State<PetsChipList> createState() => _PetsChipListState();
}

class _PetsChipListState extends State<PetsChipList> {
  int? selectedPetId;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 50),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.pets.length + 1,
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _AllPetsChip(
              selected: selectedPetId == null,
              onSelected: ({required bool selected}) {
                setState(() {
                  selectedPetId = null;
                  widget.onSelectedPetsChanged(selectedPetId);
                });
              },
            );
          }

          final pet = widget.pets[index - 1];

          return _PetChip(
            pet: pet,
            selected: selectedPetId == pet.id,
            onSelected: ({required bool selected}) {
              setState(() {
                if (selected) {
                  selectedPetId = pet.id;
                }

                widget.onSelectedPetsChanged(selectedPetId);
              });
            },
          );
        },
      ),
    );
  }
}

class _AllPetsChip extends StatelessWidget {
  final bool selected;
  final void Function({required bool selected}) onSelected;

  const _AllPetsChip({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(context.l10n.all),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      selected: selected,
      showCheckmark: false,
      labelStyle: context.uiFonts.text14Regular.copyWith(
        color: selected ? context.uiColors.white : context.uiColors.black100,
      ),
      backgroundColor: context.uiColors.white,
      selectedColor: context.uiColors.orangePrimary,
      onSelected: (value) => onSelected(selected: value),
      avatar: _AllChipAvatar(
        iconColor: selected ? context.uiColors.white : context.uiColors.black100,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _PetChip extends StatelessWidget {
  final PetModel pet;
  final bool selected;
  final void Function({required bool selected}) onSelected;

  const _PetChip({required this.pet, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      label: Text(pet.name),
      backgroundColor: context.uiColors.white,
      selected: selected,
      showCheckmark: false,
      labelStyle: context.uiFonts.text14Regular.copyWith(
        color: selected ? context.uiColors.white : context.uiColors.black100,
      ),
      selectedColor: context.uiColors.orangePrimary,
      onSelected: (value) => onSelected(selected: value),
      avatar: _PetAvatar(image: pet.image),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  final String image;
  const _PetAvatar({required this.image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: SizedBox.square(dimension: 32, child: CachedNetworkImage(imageUrl: image)),
    );
  }
}

class _AllChipAvatar extends StatelessWidget {
  final Color iconColor;

  const _AllChipAvatar({required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(dimension: 24, child: Icon(Icons.pets, color: iconColor));
  }
}
