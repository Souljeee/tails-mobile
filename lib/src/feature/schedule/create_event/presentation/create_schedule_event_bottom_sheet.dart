import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_flyout/ui_flyout.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/create_event_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/uio/create_event_uio.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/widgets/time_picker_carousel_popup.dart';

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
  late final CreateEventBloc _createEventBloc = CreateEventBloc(
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
  );

  late final ValueNotifier<CreateEventUio> _createEventUio = ValueNotifier(
    CreateEventUio(date: widget.date, petId: widget.selectedPetId),
  );

  final UiTextFieldController _eventTitleController = UiTextFieldController();
  final UiTextFieldController _dateController = UiTextFieldController();
  final UiTextFieldController _timeController = UiTextFieldController();
  final UiTextFieldController _recurrenceController = UiTextFieldController();
  final UiTextFieldController _notesController = UiTextFieldController();

  @override
  void initState() {
    super.initState();

    _dateController.text = DateFormat('dd.MM.yyyy').format(widget.date);
    _recurrenceController.text = 'Не повторять';

    _eventTitleController.addListener(_onTitleChanged);
    _timeController.addListener(_onTimeChanged);
    _notesController.addListener(_onNotesChanged);
  }

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
                ValueListenableBuilder(
                  valueListenable: _createEventUio,
                  builder: (context, uio, child) {
                    return _PetsList(
                      pets: widget.pets,
                      selectedPetId: uio.petId,
                      onPetSelected: _onPetIdSelected,
                    );
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
          BlocConsumer<CreateEventBloc, CreateEventState>(
            bloc: _createEventBloc,
            listener: (context, state) {},
            builder: (context, state) {
              return ValueListenableBuilder(
                valueListenable: _createEventUio,
                builder: (context, uio, child) {
                  return UiButton.main(
                    label: 'Готово',
                    onPressed: uio.isValid ? _createEvent : null,
                    isLoading: state.maybeMap(loading: (_) => true, orElse: () => false),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _createEvent() {
    final date = DateTime.parse(_dateController.text);

    final createEventModel = CreateEventModel(
      title: _eventTitleController.text,
      date: date,
      time: _timeController.text,
      recurrence: null,
      description: _notesController.text,
      petId: _createEventUio.value.petId!,
      type: ScheduleEventTypeEnum.custom,
      isRecurring: false,
    );

    _createEventBloc.add(CreateEventEvent.createRequested(model: createEventModel));
  }

  void _onPetIdSelected(int petId) {
    _createEventUio.value = _createEventUio.value.copyWith(petId: CopyWithWrapper.value(petId));
  }

  void _onTitleChanged() {
    final title = _eventTitleController.text;

    if (title.isEmpty) {
      return;
    }

    _createEventUio.value = _createEventUio.value.copyWith(title: CopyWithWrapper.value(title));
  }

  void _onTimeChanged() {
    final time = _timeController.text;

    if (time.isEmpty) {
      return;
    }

    _createEventUio.value = _createEventUio.value.copyWith(time: CopyWithWrapper.value(time));
  }

  void _onNotesChanged() {
    final notes = _notesController.text;

    if (notes.isEmpty) {
      return;
    }

    _createEventUio.value = _createEventUio.value.copyWith(
      description: CopyWithWrapper.value(notes),
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
        GestureDetector(
          onTap: () {
            // TODO: настройка повторения
          },
          child: IgnorePointer(
            child: UiTextField(
              controller: controller,
              placeholderText: 'Повторение',
              suffixIcon: Icons.keyboard_arrow_down_outlined,
              suffixIconColor: context.uiColors.orangePrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateTimeFields extends StatefulWidget {
  const _DateTimeFields({required this.dateController, required this.timeController});

  final UiTextFieldController dateController;
  final UiTextFieldController timeController;

  @override
  State<_DateTimeFields> createState() => _DateTimeFieldsState();
}

class _DateTimeFieldsState extends State<_DateTimeFields> {
  final String _timeInputMask = '##:##';
  final ValueNotifier<bool> _isTimePickerOpen = ValueNotifier(false);

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
                controller: widget.dateController,
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
              ValueListenableBuilder(
                valueListenable: _isTimePickerOpen,
                builder: (context, isOpen, child) {
                  return UiFlyout(
                    isOpen: isOpen,
                    anchor: const UiFlyoutAnchor( 
                      offset: Offset(0, 16),
                    ),
                    flyoutBuilder: (context) {
                      String hour = DateTime.now().hour.toString();
                      String minute = DateTime.now().minute.toString();
              
                      if (widget.timeController.text.isNotEmpty) {
                        hour = widget.timeController.text.split(':')[0];
                        minute = widget.timeController.text.split(':')[1];
                      }
              
                      return TapRegion(
                        onTapOutside: (_){
                          _isTimePickerOpen.value = false;
                        },
                        child: TimePickerCarouselPopup(
                          initialHour: int.tryParse(hour),
                          initialMinute: int.tryParse(minute),
                          onClear: () {
                            widget.timeController.clear();
                            _isTimePickerOpen.value = false;
                          },
                          onTimeSelected: (time) {
                            widget.timeController.text = time;
                          },
                        ),
                      );
                    },
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        _isTimePickerOpen.value = true;
                      },
                      child: IgnorePointer(
                        child: ValueListenableBuilder(
                          valueListenable: widget.timeController,
                          builder: (context, value, child) {
                            return UiTextField(
                              controller: widget.timeController,
                              placeholderText: 'чч:мм',
                              inputMask: _timeInputMask,
                              inputFilter: {'#': RegExp('[0-9]')},
                              trailingIcon: Icon(
                                Icons.access_time,
                                size: 24,
                                color: context.uiColors.orangePrimary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
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
