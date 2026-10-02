import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_segmented_control/ui_segmented_control.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_text_link/ui_text_link.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_editor_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/day_times_section.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/month_days_section.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_end_section.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_interval_row.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_summary_card.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/week_days_section.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/year_dates_section.dart';

/// Вторая страница шторки «Новое событие»: настройка повторения.
///
/// Итог и кнопки закреплены, настройки между ними прокручиваются. [onApply] получает черновик
/// (`null` — «Не повторять»), [onBack] закрывает страницу без изменений.
class RecurrencePage extends StatefulWidget {
  const RecurrencePage({
    required this.initial,
    required this.onApply,
    required this.onBack,
    super.key,
  });

  /// Доля высоты экрана, доступная содержимому страницы.
  static const double maxHeightFactor = 0.8;

  final RecurrenceDraft initial;
  final ValueChanged<RecurrenceDraft?> onApply;
  final VoidCallback onBack;

  @override
  State<RecurrencePage> createState() => _RecurrencePageState();
}

class _RecurrencePageState extends State<RecurrencePage> {
  late final RecurrenceEditorBloc _bloc = RecurrenceEditorBloc(draft: widget.initial);

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _change(RecurrenceDraft draft) => _bloc.add(RecurrenceEditorEvent.changed(draft));

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.sizeOf(context).height * RecurrencePage.maxHeightFactor;

    return BlocBuilder<RecurrenceEditorBloc, RecurrenceEditorState>(
      bloc: _bloc,
      builder: (context, state) {
        final draft = state.draft;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) => widget.onBack(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiSheetHeader(
                title: l10n.recurrenceTitle,
                cancelLabel: l10n.cancel,
                onCancel: widget.onBack,
              ),
              const SizedBox(height: UiSpacing.x3),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxHeight),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RecurrenceSummaryCard(draft: draft),
                    const SizedBox(height: UiSpacing.x3),
                    Flexible(
                      child: SingleChildScrollView(
                        child: _Settings(
                          draft: draft,
                          onChanged: _change,
                          onReset: () => widget.onApply(null),
                        ),
                      ),
                    ),
                    const SizedBox(height: UiSpacing.x4),
                    UiButton.main(
                      label: l10n.done,
                      onPressed: draft.canSave ? () => widget.onApply(draft) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Settings extends StatelessWidget {
  const _Settings({required this.draft, required this.onChanged, required this.onReset});

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiSegmentedControl<RecurrencePeriod>(
          options: [
            UiSegmentedOption(value: RecurrencePeriod.day, label: l10n.recurrencePeriodDay),
            UiSegmentedOption(value: RecurrencePeriod.week, label: l10n.recurrencePeriodWeek),
            UiSegmentedOption(value: RecurrencePeriod.month, label: l10n.recurrencePeriodMonth),
            UiSegmentedOption(value: RecurrencePeriod.year, label: l10n.recurrencePeriodYear),
          ],
          selected: draft.period,
          onChanged: (period) => onChanged(draft.withPeriod(period)),
        ),
        const SizedBox(height: UiSpacing.x4),
        RecurrenceIntervalRow(draft: draft, onChanged: onChanged),
        const SizedBox(height: UiSpacing.x4),
        switch (draft.period) {
          RecurrencePeriod.day ||
          RecurrencePeriod.unknown => DayTimesSection(draft: draft, onChanged: onChanged),
          RecurrencePeriod.week => WeekDaysSection(draft: draft, onChanged: onChanged),
          RecurrencePeriod.month => MonthDaysSection(draft: draft, onChanged: onChanged),
          RecurrencePeriod.year => YearDatesSection(draft: draft, onChanged: onChanged),
        },
        const SizedBox(height: UiSpacing.x4),
        RecurrenceEndSection(draft: draft, onChanged: onChanged),
        const SizedBox(height: UiSpacing.x2),
        Center(
          child: UiTextLink(label: l10n.recurrenceReset, onTap: onReset),
        ),
      ],
    );
  }
}
