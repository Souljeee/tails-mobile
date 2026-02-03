import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/domain/add_pet_bloc.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/calendar_popup.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/castration_section.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/pet_type_selection.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/photo_upload_widget.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/sex_section.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/weight_picker.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';

class AddPetFormData extends Equatable {
  final String? name;
  final PetTypeEnum? petType;
  final String? breed;
  final String? color;
  final double? weight;
  final PetSexEnum? sex;
  final DateTime? birthDate;
  final bool? castration;
  final File? image;

  const AddPetFormData({
    this.name,
    this.petType,
    this.breed,
    this.color,
    this.weight,
    this.sex,
    this.birthDate,
    this.castration,
    this.image,
  });

  bool get isValid =>
      name != null &&
      breed != null &&
      color != null &&
      weight != null &&
      sex != null &&
      birthDate != null &&
      castration != null;

  AddPetFormData copyWith({
    CopyWithWrapper<String?>? name,
    CopyWithWrapper<PetTypeEnum?>? petType,
    CopyWithWrapper<String?>? breed,
    CopyWithWrapper<String?>? color,
    CopyWithWrapper<double?>? weight,
    CopyWithWrapper<PetSexEnum?>? sex,
    CopyWithWrapper<DateTime?>? birthDate,
    CopyWithWrapper<bool?>? castration,
    CopyWithWrapper<File?>? image,
  }) =>
      AddPetFormData(
        name: name?.value ?? this.name,
        petType: petType?.value ?? this.petType,
        breed: breed?.value ?? this.breed,
        color: color?.value ?? this.color,
        weight: weight?.value ?? this.weight,
        sex: sex?.value ?? this.sex,
        birthDate: birthDate?.value ?? this.birthDate,
        castration: castration?.value ?? this.castration,
        image: image?.value ?? this.image,
      );

  @override
  List<Object?> get props => [
        name,
        petType,
        breed,
        color,
        weight,
        sex,
        birthDate,
        castration,
        image,
      ];
}

class AddPetModal extends StatefulWidget {
  const AddPetModal({super.key});

  @override
  State<AddPetModal> createState() => _AddPetModalState();
}

class _AddPetModalState extends State<AddPetModal> {
  final ValueNotifier<AddPetFormData> _formData = ValueNotifier(
    const AddPetFormData(
      castration: false,
      petType: PetTypeEnum.cat,
      sex: PetSexEnum.male,
      breed: 'норм тип',
    ),
  );

  late final AddPetBloc _addPetBloc =
      AddPetBloc(petRepository: DependenciesScope.of(context).petRepository);

  final UiTextFieldController _nameController = UiTextFieldController();
  final UiTextFieldController _birthDateController = UiTextFieldController();
  final UiTextFieldController _colorController = UiTextFieldController();
  final UiTextFieldController _breedController = UiTextFieldController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _nameController.addListener(_nameListener);
      _colorController.addListener(_colorListener);
      _breedController.addListener(_breedListener);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _colorController.dispose();
    _breedController.dispose();

    super.dispose();
  }

  void _nameListener() {
    _formData.value = _formData.value.copyWith(name: CopyWithWrapper.value(_nameController.text));
  }

  void _colorListener() {
    _formData.value = _formData.value.copyWith(color: CopyWithWrapper.value(_colorController.text));
  }

  void _breedListener() {
    _formData.value = _formData.value.copyWith(breed: CopyWithWrapper.value(_breedController.text));
  }

  void _onImageSelected(File image) {
    _formData.value = _formData.value.copyWith(image: CopyWithWrapper.value(image));
  }

  void _onTypeChanged(PetTypeEnum type) {
    _formData.value = _formData.value.copyWith(petType: CopyWithWrapper.value(type));
  }

  void _onSexChanged(PetSexEnum sex) {
    _formData.value = _formData.value.copyWith(sex: CopyWithWrapper.value(sex));
  }

  void _onWeightSelected(double weight) {
    _formData.value = _formData.value.copyWith(weight: CopyWithWrapper.value(weight));
  }

  void _onCastrationSelected(bool isSelected) {
    _formData.value = _formData.value.copyWith(castration: CopyWithWrapper.value(isSelected));
  }

  void _onBirthDateSelected(DateTime date) {
    _formData.value = _formData.value.copyWith(birthDate: CopyWithWrapper.value(date));
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

                    _onBirthDateSelected(selectedDate);
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
                sex: _formData.value.sex ?? PetSexEnum.male,
                onSelected: _onCastrationSelected,
              ),
              const SizedBox(height: 32),
              BlocBuilder<AddPetBloc, AddPetState>(
                bloc: _addPetBloc,
                builder: (context, state) {
                  return ValueListenableBuilder<AddPetFormData>(
                    valueListenable: _formData,
                    builder: (context, formData, _) {
                      return UiButton.main(
                        isLoading: state.maybeMap(
                          loading: (_) => true,
                          orElse: () => false,
                        ),
                        label: 'Сохранить',
                        onPressed: formData.isValid
                            ? state.mapOrNull(
                                initial: (_) => () {
                                  _addPetBloc.add(
                                    AddPetEvent.addingRequested(
                                      name: formData.name!,
                                      petType: formData.petType!,
                                      breed: formData.breed!,
                                      color: formData.color!,
                                      weight: formData.weight!,
                                      sex: formData.sex!,
                                      birthDate: formData.birthDate!,
                                      castration: formData.castration!,
                                      image: formData.image?.readAsBytesSync(),
                                    ),
                                  );
                                },
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
