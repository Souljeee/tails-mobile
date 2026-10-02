import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/castration_section.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/pet_type_selection.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/photo_upload_widget.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/sex_section.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/weight_picker.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

/// Поля формы питомца Design 2.0, общие для добавления и редактирования.
///
/// Состояние и логика остаются у экрана, виджет только рисует секции «Основное» и «Детали».
class PetFormBody extends StatelessWidget {
  const PetFormBody({
    required this.petType,
    required this.gender,
    required this.nameController,
    required this.breedController,
    required this.birthDateController,
    required this.colorController,
    required this.onImageSelected,
    required this.onTypeChanged,
    required this.onSexChanged,
    required this.onBreedTap,
    required this.onBirthDateTap,
    required this.onWeightSelected,
    required this.onCastrationSelected,
    this.initialImageUrl,
    this.initialWeight,
    this.initialCastration = false,
    super.key,
  });

  final PetTypeEnum? petType;
  final PetSexEnum? gender;
  final UiTextFieldController nameController;
  final UiTextFieldController breedController;
  final UiTextFieldController birthDateController;
  final UiTextFieldController colorController;

  final void Function(File image) onImageSelected;
  final void Function(PetTypeEnum type) onTypeChanged;
  final void Function(PetSexEnum sex) onSexChanged;
  final VoidCallback onBreedTap;
  final VoidCallback onBirthDateTap;
  final void Function(double weight) onWeightSelected;
  final ValueChanged<bool> onCastrationSelected;

  final String? initialImageUrl;
  final double? initialWeight;
  final bool initialCastration;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    const fieldGap = SizedBox(height: UiSpacing.x4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: PhotoUploadWidget(
            onImageSelected: onImageSelected,
            initialImageUrl: initialImageUrl,
          ),
        ),
        const SizedBox(height: UiSpacing.x6),
        UiSectionHeader(title: l10n.petFormMain),
        const SizedBox(height: UiSpacing.x2),
        _Label(l10n.petFormKind),
        PetTypeSelection(value: petType, onTypeChanged: onTypeChanged),
        fieldGap,
        UiTextField(
          controller: nameController,
          labelText: l10n.petFormName,
          placeholderText: l10n.petFormNamePlaceholder,
          capitalization: TextCapitalization.sentences,
        ),
        fieldGap,
        _Label(l10n.petFormSex),
        SexSection(value: gender, onSexChanged: onSexChanged),
        const SizedBox(height: UiSpacing.x6),
        UiSectionHeader(title: l10n.petFormDetails),
        const SizedBox(height: UiSpacing.x2),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBreedTap,
          child: AbsorbPointer(
            child: UiTextField(
              controller: breedController,
              labelText: l10n.petFormBreed,
              placeholderText: l10n.petFormBreedPlaceholder,
              trailingIcon: Icon(Icons.chevron_right, size: 24, color: palette.ink3),
            ),
          ),
        ),
        fieldGap,
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBirthDateTap,
          child: AbsorbPointer(
            child: UiTextField(
              controller: birthDateController,
              labelText: l10n.petFormBirthday,
              placeholderText: l10n.createEventDatePlaceholder,
              helperText: l10n.petFormBirthdayHint,
              trailingIcon: Icon(Icons.calendar_today_outlined, size: 24, color: palette.ink2),
            ),
          ),
        ),
        fieldGap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WeightPicker(onWeightSelected: onWeightSelected, initialWeight: initialWeight),
            ),
            const SizedBox(width: UiSpacing.x4),
            Expanded(
              child: UiTextField(
                controller: colorController,
                labelText: l10n.petFormColor,
                placeholderText: l10n.petFormColorPlaceholder,
              ),
            ),
          ],
        ),
        fieldGap,
        CastrationSection(
          gender: gender ?? PetSexEnum.male,
          initialSelection: initialCastration,
          onSelected: onCastrationSelected,
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.x2),
      child: Text(text, style: context.uiFonts.callout.copyWith(color: context.uiPalette.ink2)),
    );
  }
}
