import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics.dart';
import 'package:tails_mobile/src/core/analytics/tails_analytics_events.dart';
import 'package:tails_mobile/src/core/constant/localization/translations/app_localizations.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_calendar/ui_calendar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_discard_guard/ui_discard_guard.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_flyout/ui_flyout.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_avatar/ui_pet_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_text_link/ui_text_link.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/copy_with_wrapper.dart';
import 'package:tails_mobile/src/core/utils/extensions/date_time_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/string_extension.dart';
import 'package:tails_mobile/src/feature/initialization/widget/dependencies_scope.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/analytics/schedule_analytics.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/create_event_model.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/create_event_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/event_title_rules.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/domain/event_type_rules.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/uio/create_event_uio.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/widgets/event_type_field.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/widgets/event_type_page.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/widgets/time_picker_carousel_popup.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_calculator.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_summary.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_page.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/utils/recurrence_date_format.dart';

enum CreateScheduleEventResult { success, error }

/// Страница шторки: форма либо одна из вторых страниц.
enum _SheetPage { form, eventType, recurrence }

/// Откуда взято повторение события.
enum _RecurrenceSource {
  /// Не задано.
  none,

  /// Подставлено по типу события.
  type,

  /// Настроено пользователем (в том числе «Не повторять»).
  user,
}

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
  /// Отступы формы: шторка показывается с `fullBleed`, поэтому поля задаёт содержимое.
  static const EdgeInsets _contentPadding = EdgeInsets.fromLTRB(
    UiSpacing.x5,
    0,
    UiSpacing.x5,
    UiSpacing.x4,
  );

  late final CreateEventBloc _createEventBloc = CreateEventBloc(
    scheduleRepository: DependenciesScope.of(context).scheduleRepository,
  );

  late final ValueNotifier<CreateEventUio> _createEventUio = ValueNotifier(
    CreateEventUio(date: widget.date, petId: widget.selectedPetId),
  );

  /// Выбранный тип события; пока он не выбран, событие создать нельзя.
  final ValueNotifier<ScheduleEventTypeEnum?> _selectedType = ValueNotifier(null);

  final UiTextFieldController _eventTitleController = UiTextFieldController();
  final FocusNode _titleFocusNode = FocusNode();
  final UiTextFieldController _dateController = UiTextFieldController();
  final UiTextFieldController _timeController = UiTextFieldController();
  final UiTextFieldController _notesController = UiTextFieldController();

  /// Повторение: `null` — событие не повторяется. Хранится черновик, чтобы при смене даты
  /// и времени события нетронутые значения по умолчанию пересчитывались.
  final ValueNotifier<RecurrenceDraft?> _recurrence = ValueNotifier(null);

  final ValueNotifier<_RecurrenceSource> _recurrenceSource = ValueNotifier(_RecurrenceSource.none);

  /// Какая страница шторки открыта.
  final ValueNotifier<_SheetPage> _page = ValueNotifier(_SheetPage.form);

  /// Название в поле подставлено из типа (его не писал пользователь).
  bool _isTitleFromType = false;

  /// Название типа, на которое можно заменить своё название после смены типа.
  final ValueNotifier<String?> _titleSuggestion = ValueNotifier(null);

  /// Идёт программная запись в поле названия: слушатель не считает её правкой пользователя.
  bool _isSettingTitle = false;

  /// Ошибки показываем только после первой попытки создать событие.
  final ValueNotifier<bool> _showErrors = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _dateController.text = DateFormat('dd.MM.yyyy').format(widget.date);

    _eventTitleController.addListener(_onTitleChanged);
    _timeController.addListener(_onTimeChanged);
    _dateController.addListener(_rebaseRecurrence);
    _timeController.addListener(_rebaseRecurrence);
    _notesController.addListener(_onNotesChanged);
  }

  @override
  void dispose() {
    _createEventBloc.close();
    _createEventUio.dispose();
    _selectedType.dispose();
    _recurrence.dispose();
    _recurrenceSource.dispose();
    _page.dispose();
    _titleSuggestion.dispose();
    _titleFocusNode.dispose();
    _showErrors.dispose();
    _eventTitleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ValueListenableBuilder(
      valueListenable: _page,
      builder: (context, page, form) => switch (page) {
        _SheetPage.form => form!,
        _SheetPage.eventType => EventTypePage(
          selected: _selectedType.value,
          onSelected: _onTypeSelected,
          onBack: _showForm,
        ),
        _SheetPage.recurrence => RecurrencePage(
          initial: _recurrence.value ?? _initialRecurrenceDraft(),
          onBack: _showForm,
          onApply: _applyRecurrence,
        ),
      },
      child: ListenableBuilder(
        listenable: Listenable.merge([
          _createEventUio,
          _recurrence,
          _selectedType,
          _eventTitleController,
          _timeController,
          _notesController,
        ]),
        builder: (context, child) => UiDiscardGuard(
          hasChanges: _hasChanges,
          onDiscarded: () => TailsAnalytics.log(
            TailsAnalyticsEvents.formDiscarded(form: 'create_event', filledFields: _filledFields),
          ),
          child: child!,
        ),
        child: SafeArea(
          top: false,
          minimum: _contentPadding,
          child: Column(
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
                    errorText: _showErrors.value && uio.petId == null
                        ? l10n.createEventErrorPet
                        : null,
                  );
                },
              ),
              const SizedBox(height: UiSpacing.x4),
              _FieldLabel(label: l10n.createEventTypeLabel),
              ValueListenableBuilder(
                valueListenable: _selectedType,
                builder: (context, selected, child) =>
                    EventTypeField(selected: selected, onTap: _openEventType),
              ),
              const SizedBox(height: UiSpacing.x4),
              ListenableBuilder(
                listenable: Listenable.merge([_eventTitleController, _showErrors, _selectedType]),
                builder: (context, child) {
                  final isTitleMissing = _eventTitleController.text.trim().isEmpty;

                  return UiTextField(
                    controller: _eventTitleController,
                    focusNode: _titleFocusNode,
                    labelText: l10n.createEventNameLabel,
                    placeholderText: l10n.createEventNamePlaceholder,
                    errorText: _showErrors.value && isTitleMissing
                        ? l10n.createEventErrorTitle
                        : null,
                    helperText: _titleHint(l10n),
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: _titleSuggestion,
                builder: (context, suggestion, child) => suggestion == null
                    ? const SizedBox.shrink()
                    : _TitleSuggestion(name: suggestion, onReplace: _replaceTitle),
              ),
              const SizedBox(height: UiSpacing.x4),
              _DateTimeFields(
                initialDate: widget.date,
                dateController: _dateController,
                timeController: _timeController,
              ),
              const SizedBox(height: UiSpacing.x4),
              _RecurrenceSelector(
                recurrence: _recurrence,
                source: _recurrenceSource,
                onTap: () {
                  TailsAnalytics.log(TailsAnalyticsEvents.recurrenceOpened);
                  _page.value = _SheetPage.recurrence;
                },
              ),
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
                  return ValueListenableBuilder(
                    valueListenable: _selectedType,
                    builder: (context, type, child) => UiButton.main(
                      label: l10n.createEventSubmit,
                      // Пока тип не выбран, событие создать нельзя.
                      onPressed: type == null ? null : _submit,
                      isLoading: state.maybeMap(loading: (_) => true, orElse: () => false),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Дата события из поля (если не разобрать — исходная дата шторки).
  DateTime get _eventDate =>
      DateFormat('dd.MM.yyyy').tryParseStrict(_dateController.text.trim()) ?? widget.date;

  /// Время события `HH:mm` либо `null` («весь день»).
  String? get _eventTime {
    final time = _timeController.text.trim();

    return LocalTime.tryParse(time)?.format();
  }

  RecurrenceDraft _initialRecurrenceDraft() =>
      RecurrenceDraft.initial(eventDate: _eventDate, eventTime: _eventTime);

  /// Дата или время события изменились: нетронутые значения повторения пересчитываются.
  void _rebaseRecurrence() {
    final draft = _recurrence.value;
    if (draft == null) {
      return;
    }

    _recurrence.value = draft.rebase(eventDate: _eventDate, eventTime: _eventTime);
  }

  /// `null` — «Не повторять». Время события берётся из первого слота повторения.
  void _applyRecurrence(RecurrenceDraft? draft) {
    _page.value = _SheetPage.form;
    _recurrenceSource.value = _RecurrenceSource.user;
    _recurrence.value = draft;
    if (draft != null) {
      TailsAnalytics.log(ScheduleAnalytics.recurrenceSaved(draft.toModel()));
    }

    // Время события берётся из первого времени «в течение дня» (его можно поменять на экране
    // повторения), поэтому поле «Время» следует за ним.
    final time = draft?.resultingEventTime;
    if (time != null && time != _eventTime) {
      _timeController.text = time;
    }
  }

  /// Сколько полей заполнено (для аналитики `form_discarded`).
  int get _filledFields => [
    _eventTitleController.text.trim().isNotEmpty,
    _timeController.text.trim().isNotEmpty,
    _notesController.text.trim().isNotEmpty,
    _selectedType.value != null,
    _recurrence.value != null,
  ].where((filled) => filled).length;

  /// Пользователь что-то ввёл или изменил: заранее выбранные питомец и дата не считаются.
  bool get _hasChanges =>
      _eventTitleController.text.trim().isNotEmpty ||
      _timeController.text.trim().isNotEmpty ||
      _notesController.text.trim().isNotEmpty ||
      _selectedType.value != null ||
      _recurrence.value != null ||
      _createEventUio.value.petId != widget.selectedPetId ||
      _createEventUio.value.date != widget.date;

  /// Создаёт событие, если обязательные поля заполнены; иначе подсвечивает пустые.
  void _submit() {
    final isValid = _createEventUio.value.isValid && _eventTitleController.text.trim().isNotEmpty;

    if (!isValid) {
      _showErrors.value = true;

      return;
    }

    // Дату события могли сдвинуть за дату окончания повторения: просим поправить правило.
    if (_recurrence.value case final draft? when !draft.canSave) {
      _page.value = _SheetPage.recurrence;

      return;
    }

    _createEvent();
  }

  void _createEvent() {
    final date = DateFormat('dd.MM.yyyy').parseStrict(_dateController.text.trim());
    final recurrence = _recurrence.value?.toModel();
    // Первое из нескольких времён в день становится временем события.
    final time = recurrence != null && recurrence.times.length > 1
        ? recurrence.times.first.format()
        : _timeController.text.trim();

    final createEventModel = CreateEventModel(
      title: _eventTitleController.text,
      date: date,
      time: time.isEmpty ? null : time,
      description: _notesController.text,
      petId: _createEventUio.value.petId!,
      type: EventTypeRules.apiType(_selectedType.value!, recurrence),
      isRecurring: recurrence != null,
      recurrence: recurrence,
    );

    _createEventBloc.add(CreateEventEvent.createRequested(model: createEventModel));
  }

  void _onPetIdSelected(int petId) {
    _createEventUio.value = _createEventUio.value.copyWith(petId: CopyWithWrapper.value(petId));
  }

  void _showForm() => _page.value = _SheetPage.form;

  void _openEventType() => _page.value = _SheetPage.eventType;

  /// Подсказка под полем названия: откуда взято название либо почему оно обязательно.
  String? _titleHint(AppLocalizations l10n) {
    if (_isTitleFromType && _eventTitleController.text.isNotEmpty) {
      return l10n.createEventTitleFromType;
    }
    if (_selectedType.value == ScheduleEventTypeEnum.custom) {
      return l10n.createEventTitleOtherRequired;
    }

    return null;
  }

  void _setTitle(String title) {
    _isSettingTitle = true;
    _eventTitleController.text = title;
    _isSettingTitle = false;
  }

  /// Пользователь выбрал тип: подставляем название и повторение по правилам типа.
  void _onTypeSelected(ScheduleEventTypeEnum type) {
    final previous = _selectedType.value;
    final typeName = type.getLocalizedName(context.l10n);

    _showForm();
    _selectedType.value = type;

    final action = EventTitleRules.onTypeSelected(
      current: _eventTitleController.text,
      autofilled: _isTitleFromType,
      previousType: previous,
      newType: type,
      typeName: typeName,
    );
    switch (action) {
      case EventTitleAction.fill:
        _setTitle(typeName);
        _isTitleFromType = true;
        _titleSuggestion.value = null;
      case EventTitleAction.clear:
        _setTitle('');
        _isTitleFromType = false;
        _titleSuggestion.value = null;
      case EventTitleAction.suggest:
        _titleSuggestion.value = typeName;
      case EventTitleAction.keep:
        _titleSuggestion.value = null;
    }

    if (type == ScheduleEventTypeEnum.custom) {
      // Название для «Другое» обязательно: сразу ставим курсор в поле.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _titleFocusNode.requestFocus();
        }
      });
    }

    _applyTypeRecurrence(type);
  }

  /// «Заменить» в подсказке: подставляет название нового типа вместо своего.
  void _replaceTitle() {
    final name = _titleSuggestion.value;
    if (name == null) {
      return;
    }

    _setTitle(name);
    _isTitleFromType = true;
    _titleSuggestion.value = null;
  }

  /// Подставляет повторение по типу, пока пользователь не настраивал его сам.
  void _applyTypeRecurrence(ScheduleEventTypeEnum type) {
    if (_recurrenceSource.value == _RecurrenceSource.user) {
      return;
    }

    final period = EventTypeRules.defaultPeriod(type);
    if (period == null) {
      _recurrence.value = null;
      _recurrenceSource.value = _RecurrenceSource.none;

      return;
    }

    _recurrence.value = _initialRecurrenceDraft().withPeriod(period);
    _recurrenceSource.value = _RecurrenceSource.type;
  }

  void _onTitleChanged() {
    if (!_isSettingTitle) {
      _isTitleFromType = false;
      _titleSuggestion.value = null;
    }

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
                leading: UiPetAvatar(
                  imageUrl: pet.image,
                  placeholderAsset: pet.petType.emptyAvatarAsset,
                  size: 24,
                ),
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

/// Подсказка под названием после смены типа: «Тип изменён. Назвать «Купание»?» и «Заменить».
class _TitleSuggestion extends StatelessWidget {
  const _TitleSuggestion({required this.name, required this.onReplace});

  final String name;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.createEventTitleSuggest(name),
            style: context.uiFonts.footnote.copyWith(color: context.uiPalette.ink3),
          ),
        ),
        UiTextLink(label: l10n.createEventTitleSuggestReplace, onTap: onReplace),
      ],
    );
  }
}

class _RecurrenceSelector extends StatelessWidget {
  const _RecurrenceSelector({required this.recurrence, required this.source, required this.onTap});

  final ValueListenable<RecurrenceDraft?> recurrence;

  /// Откуда взято повторение: подставленное по типу помечается подписью.
  final ValueListenable<_RecurrenceSource> source;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return ListenableBuilder(
      listenable: Listenable.merge([recurrence, source]),
      builder: (context, child) {
        final draft = recurrence.value;
        final model = draft?.toModel();
        final title = draft == null
            ? l10n.createEventNoRecurrence
            : RecurrenceSummaryBuilder(
                l10n,
              ).build(model!, start: draft.eventDate, eventTime: draft.eventTime?.format()).title;
        final next = draft == null
            ? const <DateTime>[]
            : RecurrenceCalculator.nextOccurrences(model!, draft.eventDate);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel(label: l10n.createEventRecurrenceLabel),
            UiCard(
              showShadow: false,
              showBorder: true,
              borderRadius: UiRadius.mdAll,
              onTap: onTap,
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4, vertical: UiSpacing.x3),
              child: Row(
                children: [
                  Icon(Icons.repeat_rounded, size: 24, color: palette.ink2),
                  const SizedBox(width: UiSpacing.x3),
                  Expanded(
                    child: Text(title, style: fonts.body.copyWith(color: palette.ink)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.ink3),
                ],
              ),
            ),
            if (draft != null && source.value == _RecurrenceSource.type)
              Padding(
                padding: const EdgeInsets.only(top: UiSpacing.x2),
                child: Text(
                  l10n.recurrenceFromType,
                  style: fonts.footnote.copyWith(color: palette.ink3),
                ),
              )
            else if (next.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: UiSpacing.x2),
                child: Text(
                  l10n.recurrenceNext(
                    next
                        .map(
                          (date) => RecurrenceDateFormat.pill(
                            l10n,
                            date,
                            withYear: draft!.period == RecurrencePeriod.year,
                          ),
                        )
                        .join(', '),
                  ),
                  style: fonts.footnote.copyWith(color: palette.ink3),
                ),
              ),
          ],
        );
      },
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
