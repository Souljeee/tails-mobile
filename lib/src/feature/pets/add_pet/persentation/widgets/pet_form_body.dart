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
import 'package:tails_mobile/src/feature/pets/core/utils/pet_form_validation.dart';

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
    this.invalidFields = const {},
    this.fieldKeys = const {},
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

  /// Поля, которые нужно подсветить как незаполненные.
  final Set<PetFormField> invalidFields;

  /// Ключи полей: по ним экран прокручивает форму к первой ошибке.
  final Map<PetFormField, GlobalKey> fieldKeys;

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
        KeyedSubtree(
          key: fieldKeys[PetFormField.name],
          child: UiTextField(
            controller: nameController,
            labelText: l10n.petFormName,
            placeholderText: l10n.petFormNamePlaceholder,
            capitalization: TextCapitalization.sentences,
            errorText: invalidFields.contains(PetFormField.name) ? l10n.petFormErrorName : null,
          ),
        ),
        fieldGap,
        _Label(l10n.petFormSex),
        SexSection(value: gender, onSexChanged: onSexChanged),
        const SizedBox(height: UiSpacing.x6),
        UiSectionHeader(title: l10n.petFormDetails),
        const SizedBox(height: UiSpacing.x2),
        KeyedSubtree(
          key: fieldKeys[PetFormField.breed],
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBreedTap,
            child: AbsorbPointer(
              child: UiTextField(
                controller: breedController,
                labelText: l10n.petFormBreed,
                placeholderText: l10n.petFormBreedPlaceholder,
                errorText: invalidFields.contains(PetFormField.breed)
                    ? l10n.petFormErrorBreed
                    : null,
                trailingIcon: Icon(Icons.chevron_right, size: 24, color: palette.ink3),
              ),
            ),
          ),
        ),
        fieldGap,
        KeyedSubtree(
          key: fieldKeys[PetFormField.birthday],
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBirthDateTap,
            child: AbsorbPointer(
              child: UiTextField(
                controller: birthDateController,
                labelText: l10n.petFormBirthday,
                placeholderText: l10n.createEventDatePlaceholder,
                helperText: l10n.petFormBirthdayHint,
                errorText: invalidFields.contains(PetFormField.birthday)
                    ? l10n.petFormErrorBirthday
                    : null,
                trailingIcon: Icon(Icons.calendar_today_outlined, size: 24, color: palette.ink2),
              ),
            ),
          ),
        ),
        fieldGap,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: KeyedSubtree(
                key: fieldKeys[PetFormField.weight],
                child: WeightPicker(
                  onWeightSelected: onWeightSelected,
                  initialWeight: initialWeight,
                  errorText: invalidFields.contains(PetFormField.weight)
                      ? l10n.petFormErrorWeight
                      : null,
                ),
              ),
            ),
            const SizedBox(width: UiSpacing.x4),
            Expanded(
              child: KeyedSubtree(
                key: fieldKeys[PetFormField.color],
                child: UiTextField(
                  controller: colorController,
                  labelText: l10n.petFormColor,
                  placeholderText: l10n.petFormColorPlaceholder,
                  errorText: invalidFields.contains(PetFormField.color)
                      ? l10n.petFormErrorColor
                      : null,
                ),
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
