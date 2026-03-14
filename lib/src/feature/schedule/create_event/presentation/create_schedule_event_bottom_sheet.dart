import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';

class CreateScheduleEventBottomSheet extends StatefulWidget {
  final DateTime date;
  final List<PetModel> pets;
  final int? selectedPetId;

  const CreateScheduleEventBottomSheet({
    required this.date,
    required this.pets,
    this.selectedPetId,
    super.key,
  });

  @override
  State<CreateScheduleEventBottomSheet> createState() => _CreateScheduleEventBottomSheetState();
}

class _CreateScheduleEventBottomSheetState extends State<CreateScheduleEventBottomSheet> {
  late int? _selectedPetId = widget.selectedPetId;

  final UiTextFieldController _eventTitleController = UiTextFieldController();
  final UiTextFieldController _dateController = UiTextFieldController();
  final UiTextFieldController _timeController = UiTextFieldController();
  final UiTextFieldController _recurrenceController = UiTextFieldController();
  final UiTextFieldController _notesController = UiTextFieldController();

  @override
  Widget build(BuildContext context) {
    // 84px — отступы из ui_popup (top: 52 + bottom: 32)
    final maxHeight = MediaQuery.of(context).size.height * 0.85 - 84;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Новое событие', style: context.uiFonts.header24Semibold),
              ),
              const SizedBox(height: 16),
              _PetsList(
                pets: widget.pets,
                selectedPetId: _selectedPetId,
                onPetSelected: (petId) {
                  setState(() {
                    _selectedPetId = petId;
                  });
                },
              ),
              const SizedBox(height: 16),
              _EventTitle(controller: _eventTitleController),
              const SizedBox(height: 16),
              _DateTimeFields(dateController: _dateController, timeController: _timeController),
              const SizedBox(height: 16),
              _RecurrenceSelector(controller: _recurrenceController),
              const SizedBox(height: 16),
              _NotesField(controller: _notesController),
            ],
          ),
        ),
        const SizedBox(height: 16),
        UiButton.main(
          label: 'Готово',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
    );
  }
}

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

  final UiTextFieldController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Заметки',
          style: context.uiFonts.text16Regular.copyWith(color: context.uiColors.black60),
        ),
        const SizedBox(height: 8),
        UiTextField(controller: controller, placeholderText: 'Добавьте детали...', maxLines: 5),
      ],
    );
  }
}

class _RecurrenceSelector extends StatelessWidget {
  const _RecurrenceSelector({required this.controller});

  final UiTextFieldController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Повторение',
          style: context.uiFonts.text16Regular.copyWith(color: context.uiColors.black60),
        ),
        const SizedBox(height: 8),
        UiTextField(controller: controller, placeholderText: 'Повторение'),
      ],
    );
  }
}

class _DateTimeFields extends StatelessWidget {
  const _DateTimeFields({required this.dateController, required this.timeController});

  final UiTextFieldController dateController;
  final UiTextFieldController timeController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Дата',
                style: context.uiFonts.text16Regular.copyWith(color: context.uiColors.black60),
              ),
              const SizedBox(height: 8),
              UiTextField(
                controller: dateController,
                placeholderText: 'ДД.ММ.ГГГГ',
                trailingIcon: Icon(
                  Icons.calendar_today,
                  size: 24,
                  color: context.uiColors.orangePrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Время',
                style: context.uiFonts.text16Regular.copyWith(color: context.uiColors.black60),
              ),
              const SizedBox(height: 8),
              UiTextField(
                controller: timeController,
                placeholderText: 'чч:мм',
                trailingIcon: Icon(
                  Icons.access_time,
                  size: 24,
                  color: context.uiColors.orangePrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventTitle extends StatelessWidget {
  final UiTextFieldController controller;

  const _EventTitle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Название события',
          style: context.uiFonts.text16Regular.copyWith(color: context.uiColors.black60),
        ),
        const SizedBox(height: 8),
        UiTextField(controller: controller, placeholderText: 'Например, "Покормить кота"'),
      ],
    );
  }
}

class _PetsList extends StatelessWidget {
  final List<PetModel> pets;
  final int? selectedPetId;
  final void Function(int petId) onPetSelected;

  const _PetsList({required this.pets, required this.selectedPetId, required this.onPetSelected});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 110),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          return _PetItem(
            pet: pets[index],
            isSelected: selectedPetId == pets[index].id,
            onSelected: () => onPetSelected(pets[index].id),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 12),
      ),
    );
  }
}

class _PetItem extends StatelessWidget {
  final PetModel pet;
  final bool isSelected;
  final void Function() onSelected;

  const _PetItem({required this.pet, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox.square(
          dimension: 80,
          child: GestureDetector(
            onTap: onSelected,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.uiColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? context.uiColors.orangePrimary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      imageUrl: pet.image,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          pet.name,
          style: context.uiFonts.text14Regular.copyWith(
            color: isSelected ? context.uiColors.orangePrimary : context.uiColors.black100,
          ),
        ),
      ],
    );
  }
}
