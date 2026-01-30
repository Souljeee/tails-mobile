import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/calendar_popup.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/castration_section.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/pet_type_selection.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/photo_upload_widget.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/sex_section.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/weight_picker.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

class AddPetModal extends StatefulWidget {
  const AddPetModal({super.key});

  @override
  State<AddPetModal> createState() => _AddPetModalState();
}

class _AddPetModalState extends State<AddPetModal> {
  File? _selectedPetImage;
  PetTypeEnum _selectedPetType = PetTypeEnum.cat;
  PetSexEnum _selectedPetSex = PetSexEnum.male;
  bool _isCastrated = false;
  double? _weight;

  final UiTextFieldController _nameController = UiTextFieldController();
  final UiTextFieldController _birthDateController = UiTextFieldController();
  final UiTextFieldController _colorController = UiTextFieldController();
  final UiTextFieldController _breedController = UiTextFieldController();

  void _onImageSelected(File image) {
    setState(() {
      _selectedPetImage = image;
    });
  }

  void _onTypeChanged(PetTypeEnum type) {
    setState(() {
      _selectedPetType = type;
    });
  }

  void _onSexChanged(PetSexEnum sex) {
    setState(() {
      _selectedPetSex = sex;
    });
  }

  void _onWeightSelected(double weight) {
    setState(() {
      _weight = weight;
    });
  }

  void _onCastrationSelected(bool isSelected) {
    setState(() {
      _isCastrated = isSelected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.uiColors.white,
      appBar: AppBar(
        title: Text(
          'Добавить питомца',
          style: context.uiFonts.header24Semibold,
        ),
        backgroundColor: context.uiColors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PhotoUploadWidget(
                onImageSelected: _onImageSelected,
              ),
              const SizedBox(height: 40),
              PetTypeSelection(onTypeChanged: _onTypeChanged),
              const SizedBox(height: 16),
              Text(
                'Кличка',
                style: context.uiFonts.header20Medium,
              ),
              const SizedBox(height: 8),
              UiTextField(
                controller: _nameController,
                placeholderText: 'Наприме, Барсик',
                placeholderStyle: context.uiFonts.text16Regular.copyWith(
                  color: context.uiColors.brown,
                ),
                trailingIcon: Icon(
                  Icons.edit_outlined,
                  size: 28,
                  color: context.uiColors.brown,
                ),
              ),
              const SizedBox(height: 16),
              SexSection(onSexChanged: _onSexChanged),
              const SizedBox(height: 16),
              Text(
                'Порода',
                style: context.uiFonts.header20Medium,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Вести на выбор породы
                },
                child: AbsorbPointer(
                  child: UiTextField(
                    controller: _breedController,
                    placeholderText: 'Выберите породу',
                    placeholderStyle: context.uiFonts.text16Regular.copyWith(
                      color: context.uiColors.brown,
                    ),
                    trailingIcon: Icon(
                      Icons.search,
                      size: 28,
                      color: context.uiColors.brown,
                    ),
                    suffixIcon: Icons.keyboard_arrow_down_outlined,
                    suffixIconColor: context.uiColors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Дата рождения',
                style: context.uiFonts.header20Medium,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final DateTime? selectedDate = await CalendarPopup.show(context: context);

                  if (selectedDate != null) {
                    _birthDateController.text = DateFormat('dd.MM.yyyy').format(selectedDate);
                  }
                },
                child: AbsorbPointer(
                  child: UiTextField(
                    controller: _birthDateController,
                    placeholderText: 'ДД.ММ.ГГГГ',
                    placeholderStyle: context.uiFonts.text16Regular.copyWith(
                      color: context.uiColors.brown,
                    ),
                    trailingIcon: Icon(
                      Icons.calendar_month_outlined,
                      size: 28,
                      color: context.uiColors.brown,
                    ),
                    suffixIcon: Icons.keyboard_arrow_down_outlined,
                    suffixIconColor: context.uiColors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              WeightPicker(
                onWeightSelected: _onWeightSelected,
              ),
              const SizedBox(height: 16),
              Text(
                'Окрас',
                style: context.uiFonts.header20Medium,
              ),
              const SizedBox(height: 8),
              UiTextField(
                controller: _colorController,
                placeholderText: 'Например, рыжий',
                placeholderStyle: context.uiFonts.text16Regular.copyWith(
                  color: context.uiColors.brown,
                ),
                trailingIcon: Icon(
                  Icons.color_lens_outlined,
                  size: 28,
                  color: context.uiColors.brown,
                ),
              ),
              const SizedBox(height: 16),
              CastrationSection(
                sex: _selectedPetSex,
                onSelected: _onCastrationSelected,
              ),
              const SizedBox(height: 32),
              UiButton.main(
                label: 'Сохранить',
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
