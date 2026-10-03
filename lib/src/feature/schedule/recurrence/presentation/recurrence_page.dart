import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_text_link/ui_text_link.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/recurrence_types.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_editor_bloc.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/recurrence_panel.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/day_times_section.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/month_days_section.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_end_section.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_panel_view.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_period_card.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/recurrence_summary_card.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/week_days_section.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/presentation/widgets/year_dates_section.dart';

/// Вторая страница шторки «Новое событие»: настройка повторения.
///
/// Страница рассчитана на шторку с `fullBleed` и сама задаёт боковые поля и нижнюю безопасную зону.
///
/// Итог закреплён сверху, настройки прокручиваются, внизу — «Сохранить», а пока открыт барабан —
/// панель барабана. [onApply] получает черновик (`null` — «Не повторять»), [onBack] закрывает
/// страницу без изменений.
class RecurrencePage extends StatefulWidget {
  const RecurrencePage({
    required this.initial,
    required this.onApply,
    required this.onBack,
    super.key,
  });

  /// Доля высоты экрана, которую занимает страница: высота не прыгает между периодами.
  static const double heightFactor = 0.86;

  /// Боковые поля содержимого; шторка показывается с `fullBleed`, чтобы панель барабана
  /// занимала всю ширину.
  static const EdgeInsets _sidePadding = EdgeInsets.symmetric(horizontal: UiSpacing.x5);

  final RecurrenceDraft initial;
  final ValueChanged<RecurrenceDraft?> onApply;
  final VoidCallback onBack;

  @override
  State<RecurrencePage> createState() => _RecurrencePageState();
}

class _RecurrencePageState extends State<RecurrencePage> {
  late final RecurrenceEditorBloc _bloc = RecurrenceEditorBloc(draft: widget.initial);

  RecurrencePanel? _panel;

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _change(RecurrenceDraft draft) => _bloc.add(RecurrenceEditorEvent.changed(draft));

  void _setPanel(RecurrencePanel? panel) => setState(() => _panel = panel);

  /// Назад: сначала закрывает барабан, затем страницу.
  void _onBack() {
    if (_panel != null) {
      _setPanel(null);

      return;
    }
    widget.onBack();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final height = MediaQuery.sizeOf(context).height * RecurrencePage.heightFactor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onBack(),
      child: BlocBuilder<RecurrenceEditorBloc, RecurrenceEditorState>(
        bloc: _bloc,
        builder: (context, state) {
          final draft = state.draft;
          final panel = _panel;

          return SizedBox(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: RecurrencePage._sidePadding,
                  child: UiSheetHeader.back(
                    title: l10n.recurrenceTitle,
                    backLabel: l10n.recurrenceBack,
                    onCancel: widget.onBack,
                  ),
                ),
                const SizedBox(height: UiSpacing.x3),
                Padding(
                  padding: RecurrencePage._sidePadding,
                  child: RecurrenceSummaryCard(draft: draft),
                ),
                const SizedBox(height: UiSpacing.x3),
                Expanded(
                  child: SingleChildScrollView(
                    padding: RecurrencePage._sidePadding,
                    child: _Settings(
                      draft: draft,
                      onChanged: _change,
                      panel: panel,
                      onPanel: _setPanel,
                      onReset: () => widget.onApply(null),
                    ),
                  ),
                ),
                const SizedBox(height: UiSpacing.x3),
                if (panel == null)
                  SafeArea(
                    top: false,
                    minimum: const EdgeInsets.only(bottom: UiSpacing.x4),
                    child: Padding(
                      padding: RecurrencePage._sidePadding,
                      child: UiButton.main(
                        label: l10n.recurrenceSave,
                        onPressed: draft.canSave ? () => widget.onApply(draft) : null,
                      ),
                    ),
                  )
                else
                  RecurrencePanelView(
                    key: ValueKey(panel is RecurrencePanel$Time ? 'time' : panel),
                    panel: panel,
                    draft: draft,
                    onChanged: _change,
                    onPanel: _setPanel,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Settings extends StatelessWidget {
  const _Settings({
    required this.draft,
    required this.onChanged,
    required this.panel,
    required this.onPanel,
    required this.onReset,
  });

  final RecurrenceDraft draft;
  final ValueChanged<RecurrenceDraft> onChanged;
  final RecurrencePanel? panel;
  final ValueChanged<RecurrencePanel?> onPanel;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RecurrencePeriodCard(draft: draft, onChanged: onChanged),
        const SizedBox(height: UiSpacing.x4),
        switch (draft.period) {
          RecurrencePeriod.day || RecurrencePeriod.unknown => DayTimesSection(
            draft: draft,
            onChanged: onChanged,
            panel: panel,
            onPanel: onPanel,
          ),
          RecurrencePeriod.week => WeekDaysSection(draft: draft, onChanged: onChanged),
          RecurrencePeriod.month => MonthDaysSection(draft: draft, onChanged: onChanged),
          RecurrencePeriod.year => YearDatesSection(draft: draft, panel: panel, onPanel: onPanel),
        },
        const SizedBox(height: UiSpacing.x4),
        RecurrenceEndSection(draft: draft, onChanged: onChanged, panel: panel, onPanel: onPanel),
        const SizedBox(height: UiSpacing.x2),
        Center(
          child: UiTextLink(label: context.l10n.recurrenceReset, onTap: onReset),
        ),
      ],
    );
  }
}
