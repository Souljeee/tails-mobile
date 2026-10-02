import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/navigation/routes.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_snack_bar/ui_snack_bar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/domain/add_pet_bloc.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/calendar_popup.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/pet_form_body.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/breed_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_form_validation.dart';

class AddPetFormData extends Equatable {
  final String? name;
  final PetTypeEnum? petType;
  final int? breedId;
  final String? color;
  final double? weight;
  final PetSexEnum? gender;
  final DateTime? birthday;
  final bool? castration;
  final File? image;

  const AddPetFormData({
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
      breedId != null &&
      color != null &&
      weight != null &&
      gender != null &&
      birthday != null &&
      castration != null;

  AddPetFormData copyWith({
    CopyWithWrapper<String?>? name,
    CopyWithWrapper<PetTypeEnum?>? petType,
    CopyWithWrapper<int?>? breedId,
    CopyWithWrapper<String?>? color,
    CopyWithWrapper<double?>? weight,
    CopyWithWrapper<PetSexEnum?>? gender,
    CopyWithWrapper<DateTime?>? birthday,
    CopyWithWrapper<bool?>? castration,
    CopyWithWrapper<File?>? image,
  }) => AddPetFormData(
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

class AddPetModal extends StatefulWidget {
  const AddPetModal({super.key});

  @override
  State<AddPetModal> createState() => _AddPetModalState();
}

class _AddPetModalState extends State<AddPetModal> {
  final ValueNotifier<AddPetFormData> _formData = ValueNotifier(
    const AddPetFormData(castration: false, petType: PetTypeEnum.cat, gender: PetSexEnum.male),
  );

  late final AddPetBloc _addPetBloc = AddPetBloc(
    petRepository: DependenciesScope.of(context).petRepository,
  );

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

  final Map<PetFormField, GlobalKey> _fieldKeys = {
    for (final field in PetFormField.values) field: GlobalKey(),
  };

  /// Ошибки показываем только после первой попытки отправить форму.
  bool _showErrors = false;

  List<PetFormField> _missingFields(AddPetFormData formData) => findMissingPetFormFields(
    name: formData.name,
    breedId: formData.breedId,
    birthday: formData.birthday,
    weight: formData.weight,
    color: formData.color,
  );

  /// Возвращает `true`, если форма заполнена. Иначе подсвечивает пустые поля и
  /// прокручивает форму к первому из них.
  bool _validate(AddPetFormData formData) {
    final missing = _missingFields(formData);

    if (missing.isEmpty) {
      return true;
    }

    setState(() => _showErrors = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fieldContext = _fieldKeys[missing.first]?.currentContext;

      if (fieldContext != null && fieldContext.mounted) {
        Scrollable.ensureVisible(
          fieldContext,
          duration: UiMotion.base,
          curve: UiMotion.curve,
          alignment: 0.1,
        );
      }
    });

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.uiPalette.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
              child: UiSheetHeader(title: l10n.addPetTitle, cancelLabel: l10n.cancel),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  UiSpacing.x5,
                  UiSpacing.x4,
                  UiSpacing.x5,
                  UiSpacing.x4,
                ),
                child: ValueListenableBuilder<AddPetFormData>(
                  valueListenable: _formData,
                  builder: (context, formData, _) {
                    return PetFormBody(
                      petType: formData.petType,
                      gender: formData.gender,
                      nameController: _nameController,
                      breedController: _breedController,
                      birthDateController: _birthDateController,
                      colorController: _colorController,
                      onImageSelected: _onImageSelected,
                      onTypeChanged: _onTypeChanged,
                      onSexChanged: _onSexChanged,
                      onWeightSelected: _onWeightSelected,
                      onCastrationSelected: _onCastrationSelected,
                      onBreedTap: _selectBreed,
                      onBirthDateTap: _selectBirthDate,
                      invalidFields: _showErrors ? _missingFields(formData).toSet() : const {},
                      fieldKeys: _fieldKeys,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                UiSpacing.x5,
                UiSpacing.x2,
                UiSpacing.x5,
                UiSpacing.x4,
              ),
              child: BlocConsumer<AddPetBloc, AddPetState>(
                bloc: _addPetBloc,
                listener: (context, state) {
                  state.mapOrNull(
                    success: (_) => Navigator.of(context).pop(),
                    error: (_) => showUiSnackBar(context, message: l10n.tryLater),
                  );
                },
                builder: (context, state) {
                  return ValueListenableBuilder<AddPetFormData>(
                    valueListenable: _formData,
                    builder: (context, formData, _) {
                      return UiButton.main(
                        isLoading: state.maybeMap(loading: (_) => true, orElse: () => false),
                        label: l10n.addPetSubmit,
                        onPressed: state.mapOrNull(
                          initial: (_) => () {
                            if (!_validate(formData)) {
                              return;
                            }

                            _addPetBloc.add(
                              AddPetEvent.addingRequested(
                                name: formData.name!,
                                petType: formData.petType!,
                                breedId: formData.breedId!,
                                color: formData.color!,
                                weight: formData.weight!,
                                gender: formData.gender!,
                                birthday: formData.birthday!,
                                castration: formData.castration!,
                                image: formData.image,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBreed() async {
    final BreedModel? breed = await SelectBreedRoute(
      petType: _formData.value.petType ?? PetTypeEnum.cat,
      selectedBreedId: _formData.value.breedId,
    ).push<BreedModel>(context);

    if (breed != null) {
      _breedController.text = breed.name;
      _onBreedSelected(breed);
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? selectedDate = await CalendarPopup.show(context: context);

    if (selectedDate != null) {
      _birthDateController.text = DateFormat('dd.MM.yyyy').format(selectedDate);

      _onBirthDateSelected(selectedDate);
    }
  }
}
