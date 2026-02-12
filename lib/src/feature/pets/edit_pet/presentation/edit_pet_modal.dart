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
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/calendar_popup.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/castration_section.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/pet_type_selection.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/photo_upload_widget.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/sex_section.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/weight_picker.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/edit_pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_details_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/edit_pet/domain/edit_pet_bloc.dart';
import 'package:tails_mobile/src/feature/pets/select_breed/presentation/select_breed_modal.dart';

class EditPetFormData extends Equatable {
  final String? name;
  final PetTypeEnum? petType;
  final int? breedId;
  final String? color;
  final double? weight;
  final PetSexEnum? gender;
  final DateTime? birthday;
  final bool? castration;
  final File? image;

  const EditPetFormData({
    this.name,
    this.petType,
    this.breedId,
    this.color,
    this.weight,
    this.gender,
    this.birthday,
    this.castration,
    this.image,
  });

  bool get isValid =>
      name != null &&
      name!.trim().isNotEmpty &&
      petType != null &&
      breedId != null &&
      color != null &&
      color!.trim().isNotEmpty &&
      weight != null &&
      gender != null &&
      birthday != null &&
      castration != null;

  EditPetFormData copyWith({
    CopyWithWrapper<String?>? name,
    CopyWithWrapper<PetTypeEnum?>? petType,
    CopyWithWrapper<int?>? breedId,
    CopyWithWrapper<String?>? color,
    CopyWithWrapper<double?>? weight,
    CopyWithWrapper<PetSexEnum?>? gender,
    CopyWithWrapper<DateTime?>? birthday,
    CopyWithWrapper<bool?>? castration,
    CopyWithWrapper<File?>? image,
  }) => EditPetFormData(
    name: name?.value ?? this.name,
    petType: petType?.value ?? this.petType,
    breedId: breedId?.value ?? this.breedId,
    color: color?.value ?? this.color,
    weight: weight?.value ?? this.weight,
    gender: gender?.value ?? this.gender,
    birthday: birthday?.value ?? this.birthday,
    castration: castration?.value ?? this.castration,
    image: image?.value ?? this.image,
  );

  @override
  List<Object?> get props => [
    name,
    petType,
    breedId,
    color,
    weight,
    gender,
    birthday,
    castration,
    image,
  ];
}

class EditPetModal extends StatefulWidget {
  final PetDetailsModel pet;

  const EditPetModal({required this.pet, super.key});

  @override
  State<EditPetModal> createState() => _EditPetModalState();
}

class _EditPetModalState extends State<EditPetModal> {
  late final ValueNotifier<EditPetFormData> _formData = ValueNotifier(
    EditPetFormData(
      name: widget.pet.name,
      petType: widget.pet.petType,
      breedId: widget.pet.breed.id,
      color: widget.pet.color,
      weight: widget.pet.weight,
      gender: widget.pet.gender,
      birthday: widget.pet.birthday,
      castration: widget.pet.hasCastration,
    ),
  );

  late final EditPetBloc _editPetBloc = EditPetBloc(
    petRepository: DependenciesScope.of(context).petRepository,
  );

  late final UiTextFieldController _nameController = UiTextFieldController(text: widget.pet.name);
  late final UiTextFieldController _birthDateController = UiTextFieldController(
    text: DateFormat('dd.MM.yyyy').format(widget.pet.birthday),
  );
  late final UiTextFieldController _colorController = UiTextFieldController(text: widget.pet.color);
  late final UiTextFieldController _breedController = UiTextFieldController(
    text: widget.pet.breed.name,
  );

  @override
  void initState() {
    super.initState();

    _nameController.addListener(_nameListener);
    _colorController.addListener(_colorListener);
  }

  @override
  void dispose() {
    _formData.dispose();
    _editPetBloc.close();

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

  void _onBreedSelected(BreedModel breed) {
    _formData.value = _formData.value.copyWith(breedId: CopyWithWrapper.value(breed.id));
  }

  void _onImageSelected(File image) {
    _formData.value = _formData.value.copyWith(image: CopyWithWrapper.value(image));
  }

  void _onTypeChanged(PetTypeEnum type) {
    _formData.value = _formData.value.copyWith(petType: CopyWithWrapper.value(type));
  }

  void _onSexChanged(PetSexEnum gender) {
    _formData.value = _formData.value.copyWith(gender: CopyWithWrapper.value(gender));
  }

  void _onWeightSelected(double weight) {
    _formData.value = _formData.value.copyWith(weight: CopyWithWrapper.value(weight));
  }

  void _onCastrationSelected(bool isSelected) {
    _formData.value = _formData.value.copyWith(castration: CopyWithWrapper.value(isSelected));
  }

  void _onBirthDateSelected(DateTime date) {
    _formData.value = _formData.value.copyWith(birthday: CopyWithWrapper.value(date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.uiColors.white,
      appBar: AppBar(
        title: Text('Изменить', style: context.uiFonts.header24Semibold),
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
                initialImageUrl: widget.pet.image,
              ),
              const SizedBox(height: 40),
              PetTypeSelection(onTypeChanged: _onTypeChanged),
              const SizedBox(height: 16),
              Text('Кличка', style: context.uiFonts.header20Medium),
              const SizedBox(height: 8),
              UiTextField(
                controller: _nameController,
                placeholderText: 'Наприме, Барсик',
                placeholderStyle: context.uiFonts.text16Regular.copyWith(
                  color: context.uiColors.brown,
                ),
                trailingIcon: Icon(Icons.edit_outlined, size: 28, color: context.uiColors.brown),
              ),
              const SizedBox(height: 16),
              SexSection(onSexChanged: _onSexChanged),
              const SizedBox(height: 16),
              Text('Порода', style: context.uiFonts.header20Medium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final BreedModel? breed = await Navigator.of(context).push<BreedModel>(
                    MaterialPageRoute(
                      builder: (context) =>
                          SelectBreedModal(petType: _formData.value.petType ?? PetTypeEnum.cat),
                    ),
                  );

                  if (breed != null) {
                    _breedController.text = breed.name;
                    _onBreedSelected(breed);
                  }
                },
                child: AbsorbPointer(
                  child: UiTextField(
                    controller: _breedController,
                    placeholderText: 'Выберите породу',
                    placeholderStyle: context.uiFonts.text16Regular.copyWith(
                      color: context.uiColors.brown,
                    ),
                    trailingIcon: Icon(Icons.search, size: 28, color: context.uiColors.brown),
                    suffixIcon: Icons.keyboard_arrow_down_outlined,
                    suffixIconColor: context.uiColors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Дата рождения', style: context.uiFonts.header20Medium),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final DateTime? selectedDate = await CalendarPopup.show(
                    context: context,
                    initialDate: _formData.value.birthday ?? widget.pet.birthday,
                  );

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
              WeightPicker(onWeightSelected: _onWeightSelected, initialWeight: widget.pet.weight),
              const SizedBox(height: 16),
              Text('Окрас', style: context.uiFonts.header20Medium),
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
              ValueListenableBuilder(
                valueListenable: _formData,
                builder: (context, formData, _) {
                  return CastrationSection(
                    initialSelection: widget.pet.hasCastration,
                    gender: formData.gender ?? PetSexEnum.male,
                    onSelected: _onCastrationSelected,
                  );
                },
              ),
              const SizedBox(height: 32),
              BlocConsumer<EditPetBloc, EditPetState>(
                bloc: _editPetBloc,
                listener: (context, state) {
                  state.mapOrNull(
                    success: (_) => Navigator.of(context).pop(),
                    error: (e) => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Произошла ошибка. Повторите позднее.',
                          style: context.uiFonts.text16Regular.copyWith(
                            color: context.uiColors.white,
                          ),
                        ),
                        backgroundColor: context.uiColors.red,
                      ),
                    ),
                  );
                },
                builder: (context, state) {
                  return ValueListenableBuilder<EditPetFormData>(
                    valueListenable: _formData,
                    builder: (context, formData, _) {

                      final isFormValid = formData.isValid && _hasChanges(formData);

                      return UiButton.main(
                        isLoading: state.maybeMap(loading: (_) => true, orElse: () => false),
                        label: 'Сохранить',
                        onPressed: isFormValid
                            ? state.mapOrNull(
                                initial: (_) => () {
                                  _editPetBloc.add(
                                    EditPetEvent.editingRequested(
                                      petId: widget.pet.id,
                                      pet: EditPetModel(
                                        name: formData.name,
                                        petType: formData.petType,
                                        breedId: formData.breedId,
                                        color: formData.color,
                                        weight: formData.weight,
                                        gender: formData.gender,
                                        birthday: formData.birthday,
                                      ),
                                      image: _formData.value.image,
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

  bool _hasChanges(EditPetFormData formData) {
    String norm(String? s) => (s ?? '').trim();

    bool sameDate(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final initialBirthday = widget.pet.birthday;
    final currentBirthday = formData.birthday;
    final birthdayChanged = currentBirthday == null ? false : !sameDate(currentBirthday, initialBirthday);

    final initialWeight = widget.pet.weight;
    final currentWeight = formData.weight;
    final weightChanged = currentWeight == null ? false : (currentWeight - initialWeight).abs() > 1e-9;

    return norm(formData.name) != norm(widget.pet.name) ||
        formData.petType != widget.pet.petType ||
        formData.breedId != widget.pet.breed.id ||
        norm(formData.color) != norm(widget.pet.color) ||
        weightChanged ||
        formData.gender != widget.pet.gender ||
        birthdayChanged ||
        formData.castration != widget.pet.hasCastration ||
        // Важно: иначе смена фото сама по себе не активирует кнопку
        formData.image != null;
  }
}
