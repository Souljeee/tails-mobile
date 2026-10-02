import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_selectable_card/ui_selectable_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

/// Выбор вида питомца: две карточки-радио «Кошка / Собака».
class PetTypeSelection extends StatelessWidget {
  final PetTypeEnum? value;
  final void Function(PetTypeEnum type) onTypeChanged;

  const PetTypeSelection({required this.value, required this.onTypeChanged, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final icons = context.uiIcons;
    final color = context.uiPalette.ink;

    // TODO: заменить временные иконки кошки и собаки на финальные из набора.
    return Row(
      children: [
        Expanded(
          child: UiSelectableCard(
            label: l10n.cat,
            selected: value == PetTypeEnum.cat,
            leading: UiSvgImage(
              svgPath: icons.placeholderCat.path,
              color: color,
              height: 22,
              width: 22,
            ),
            onTap: () => onTypeChanged(PetTypeEnum.cat),
          ),
        ),
        const SizedBox(width: UiSpacing.x3),
        Expanded(
          child: UiSelectableCard(
            label: l10n.dog,
            selected: value == PetTypeEnum.dog,
            leading: UiSvgImage(
              svgPath: icons.placeholderDog.path,
              color: color,
              height: 22,
              width: 22,
            ),
            onTap: () => onTypeChanged(PetTypeEnum.dog),
          ),
        ),
      ],
    );
  }
}
