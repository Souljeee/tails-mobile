import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_flyout/ui_flyout.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_avatar/ui_pet_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/core/utils/extensions/date_time_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/string_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/create_event_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/uio/create_event_uio.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/utils/event_type_options.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/widgets/time_picker_carousel_popup.dart';

enum CreateScheduleEventResult { success, error }

/// Содержимое sheet «Новое событие». Показывается через `showUiBottomSheet`.
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

  /// Выбранный чип типа; если ничего не выбрано, отправляется `custom`, как и раньше.
  final ValueNotifier<ScheduleEventTypeEnum?> _selectedType = ValueNotifier(null);

  final UiTextFieldController _eventTitleController = UiTextFieldController();
  final UiTextFieldController _dateController = UiTextFieldController();
  final UiTextFieldController _timeController = UiTextFieldController();
  final UiTextFieldController _recurrenceController = UiTextFieldController();
  final UiTextFieldController _notesController = UiTextFieldController();

  /// Ошибки показываем только после первой попытки создать событие.
  final ValueNotifier<bool> _showErrors = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _dateController.text = DateFormat('dd.MM.yyyy').format(widget.date);

    _eventTitleController.addListener(_onTitleChanged);
    _timeController.addListener(_onTimeChanged);
    _notesController.addListener(_onNotesChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_recurrenceController.text.isEmpty) {
      _recurrenceController.text = context.l10n.createEventNoRecurrence;
    }
  }

  @override
  void dispose() {
    _createEventBloc.close();
    _createEventUio.dispose();
    _selectedType.dispose();
    _showErrors.dispose();
    _eventTitleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _recurrenceController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiSheetHeader(title: l10n.createEventTitle, cancelLabel: l10n.cancel),
        const SizedBox(height: UiSpacing.x4),
        _FieldLabel(label: l10n.createEventForWhom),
        ListenableBuilder(
          listenable: Listenable.merge([_createEventUio, _showErrors]),
          builder: (context, child) {
            final uio = _createEventUio.value;

            return _PetChips(
              pets: widget.pets,
              selectedPetId: uio.petId,
              onPetSelected: _onPetIdSelected,
              errorText: _showErrors.value && uio.petId == null ? l10n.createEventErrorPet : null,
            );
          },
        ),
        const SizedBox(height: UiSpacing.x4),
        ListenableBuilder(
          listenable: Listenable.merge([_eventTitleController, _showErrors]),
          builder: (context, child) {
            final isTitleMissing = _eventTitleController.text.trim().isEmpty;

            return UiTextField(
              controller: _eventTitleController,
              labelText: l10n.createEventNameLabel,
              placeholderText: l10n.createEventNamePlaceholder,
              errorText: _showErrors.value && isTitleMissing ? l10n.createEventErrorTitle : null,
            );
          },
        ),
        const SizedBox(height: UiSpacing.x4),
        _FieldLabel(label: l10n.createEventTypeLabel),
        ValueListenableBuilder(
          valueListenable: _selectedType,
          builder: (context, selected, child) {
            return _TypeChips(selected: selected, onSelected: (type) => _selectedType.value = type);
          },
        ),
        const SizedBox(height: UiSpacing.x4),
        _DateTimeFields(
          initialDate: widget.date,
          dateController: _dateController,
          timeController: _timeController,
        ),
        const SizedBox(height: UiSpacing.x4),
        _RecurrenceSelector(controller: _recurrenceController),
        const SizedBox(height: UiSpacing.x4),
        UiTextField(
          controller: _notesController,
          labelText: l10n.createEventNotesLabel,
          placeholderText: l10n.createEventNotesPlaceholder,
          maxLines: 4,
        ),
        const SizedBox(height: UiSpacing.x5),
        BlocConsumer<CreateEventBloc, CreateEventState>(
          bloc: _createEventBloc,
          listener: (context, state) {
            state.mapOrNull(
              success: (_) => Navigator.of(context).pop(CreateScheduleEventResult.success),
              error: (_) => Navigator.of(context).pop(CreateScheduleEventResult.error),
            );
          },
          builder: (context, state) {
            return UiButton.main(
              label: l10n.createEventSubmit,
              onPressed: _submit,
              isLoading: state.maybeMap(loading: (_) => true, orElse: () => false),
            );
          },
        ),
      ],
    );
  }

  /// Создаёт событие, если обязательные поля заполнены; иначе подсвечивает пустые.
  void _submit() {
    final isValid = _createEventUio.value.isValid && _eventTitleController.text.trim().isNotEmpty;

    if (!isValid) {
      _showErrors.value = true;

      return;
    }

    _createEvent();
  }

  void _createEvent() {
    final date = DateFormat('dd.MM.yyyy').parseStrict(_dateController.text.trim());
    final time = _timeController.text.trim();

    final createEventModel = CreateEventModel(
      title: _eventTitleController.text,
      date: date,
      time: time.isEmpty ? null : time,
      description: _notesController.text,
      petId: _createEventUio.value.petId!,
      type: _selectedType.value ?? ScheduleEventTypeEnum.custom,
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

/// Подпись над группой чипов (для полей ввода подпись рисует сам `UiTextField`).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpacing.x2),
      child: Text(label, style: context.uiFonts.callout.copyWith(color: context.uiPalette.ink2)),
    );
  }
}

class _PetChips extends StatelessWidget {
  const _PetChips({
    required this.pets,
    required this.selectedPetId,
    required this.onPetSelected,
    this.errorText,
  });

  final List<PetModel> pets;
  final int? selectedPetId;
  final void Function(int petId) onPetSelected;

  /// Подсказка под чипами, если питомец не выбран после попытки создать событие.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final error = errorText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: UiSpacing.x2,
          runSpacing: UiSpacing.x2,
          children: [
            for (final pet in pets)
              UiChip(
                label: pet.name,
                selected: selectedPetId == pet.id,
                onTap: () => onPetSelected(pet.id),
                leading: UiPetAvatar(imageUrl: pet.image, size: 24),
              ),
          ],
        ),
        if (error != null) ...[
          const SizedBox(height: UiSpacing.x2),
          Text(error, style: context.uiFonts.footnote.copyWith(color: context.uiPalette.danger)),
        ],
      ],
    );
  }
}

class _TypeChips extends StatelessWidget {
  const _TypeChips({required this.selected, required this.onSelected});

  final ScheduleEventTypeEnum? selected;
  final ValueChanged<ScheduleEventTypeEnum> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final l10n = context.l10n;

    return Wrap(
      spacing: UiSpacing.x2,
      runSpacing: UiSpacing.x2,
      children: [
        for (final option in eventTypeOptions)
          UiChip(
            label: option.labelOf(l10n),
            selected: selected == option.type,
            onTap: () => onSelected(option.type),
            leading: Icon(
              option.icon,
              size: 18,
              color: selected == option.type ? palette.surface : palette.ink2,
            ),
          ),
      ],
    );
  }
}

class _RecurrenceSelector extends StatelessWidget {
  const _RecurrenceSelector({required this.controller});

  final UiTextFieldController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // TODO: настройка повторения
      },
      child: IgnorePointer(
        child: UiTextField(
          controller: controller,
          labelText: l10n.createEventRecurrenceLabel,
          placeholderText: l10n.createEventRecurrenceLabel,
          // TODO: заменить временную иконку повтора на финальную из набора.
          trailingIcon: UiSvgImage(
            svgPath: context.uiIcons.placeholderRepeat.path,
            color: context.uiPalette.ink2,
          ),
        ),
      ),
    );
  }
}

class _DateTimeFields extends StatefulWidget {
  const _DateTimeFields({
    required this.initialDate,
    required this.dateController,
    required this.timeController,
  });

  final DateTime initialDate;
  final UiTextFieldController dateController;
  final UiTextFieldController timeController;

  @override
  State<_DateTimeFields> createState() => _DateTimeFieldsState();
}

class _DateTimeFieldsState extends State<_DateTimeFields> {
  final String _timeInputMask = '##:##';
  final ValueNotifier<bool> _isTimePickerOpen = ValueNotifier(false);
  final ValueNotifier<bool> _isDatePickerOpen = ValueNotifier(false);

  @override
  void dispose() {
    _isTimePickerOpen.dispose();
    _isDatePickerOpen.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final iconColor = context.uiPalette.ink2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _isDatePickerOpen,
            builder: (context, isOpen, child) {
              return UiFlyout(
                isOpen: isOpen,
                anchor: const UiFlyoutAnchor(
                  offset: Offset(16, 0),
                  anchorAlignment: Alignment.centerLeft,
                  flyoutAlignment: Alignment.centerLeft,
                ),
                flyoutBuilder: (context) {
                  return TapRegion(
                    onTapOutside: (_) {
                      _isDatePickerOpen.value = false;
                    },
                    child: _DatePickerCalendarPopup(
                      initialDate: widget.initialDate,
                      onDateSelected: (date) {
                        widget.dateController.text = DateFormat('dd.MM.yyyy').format(date);
                        _isDatePickerOpen.value = false;
                      },
                    ),
                  );
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _isDatePickerOpen.value = true;
                  },
                  child: IgnorePointer(
                    child: UiTextField(
                      controller: widget.dateController,
                      labelText: l10n.createEventDateLabel,
                      placeholderText: l10n.createEventDatePlaceholder,
                      trailingIcon: Icon(Icons.calendar_today_outlined, size: 24, color: iconColor),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: UiSpacing.x4),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _isTimePickerOpen,
            builder: (context, isOpen, child) {
              return UiFlyout(
                isOpen: isOpen,
                anchor: const UiFlyoutAnchor(offset: Offset(0, 16)),
                flyoutBuilder: (context) {
                  String hour = DateTime.now().hour.toString();
                  String minute = DateTime.now().minute.toString();

                  if (widget.timeController.text.isNotEmpty) {
                    hour = widget.timeController.text.split(':')[0];
                    minute = widget.timeController.text.split(':')[1];
                  }

                  return TapRegion(
                    onTapOutside: (_) {
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
                          labelText: l10n.createEventTimeLabel,
                          placeholderText: l10n.createEventTimePlaceholder,
                          inputMask: _timeInputMask,
                          inputFilter: {'#': RegExp('[0-9]')},
                          trailingIcon: Icon(Icons.schedule, size: 24, color: iconColor),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DatePickerCalendarPopup extends StatelessWidget {
  const _DatePickerCalendarPopup({required this.initialDate, required this.onDateSelected});

  final DateTime initialDate;
  final OnDateTapCallback onDateSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: UiRadius.lgAll,
        border: Border.all(color: palette.line),
        boxShadow: UiShadows.e2,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x3, vertical: UiSpacing.x2),
        child: SizedBox(
          width: 320,
          child: MonthCalendar(
            initialMonth: initialDate,
            onDateTap: onDateSelected,
            headerBuilder: (month, nextMonthButtonHandler, previousMonthButtonHandler, _, _) {
              final formattedMonth = DateFormat.yMMMM(
                Localizations.localeOf(context).toString(),
              ).format(month).replaceAll(' г.', '').toFirstLetterUpperCase();

              return Row(
                children: [
                  Expanded(
                    child: Text(
                      formattedMonth,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.uiFonts.headline.copyWith(color: palette.ink),
                    ),
                  ),
                  IconButton(
                    onPressed: previousMonthButtonHandler,
                    icon: const Icon(Icons.chevron_left),
                    color: palette.accent,
                  ),
                  IconButton(
                    onPressed: nextMonthButtonHandler,
                    icon: const Icon(Icons.chevron_right),
                    color: palette.accent,
                  ),
                ],
              );
            },
            style: CalendarStyle(
              resolveDateTextColor: (date) =>
                  initialDate.isSameDate(date) ? palette.surface : palette.ink,
              resolveDateBackgroundColor: (date) =>
                  initialDate.isSameDate(date) ? palette.accent : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}
