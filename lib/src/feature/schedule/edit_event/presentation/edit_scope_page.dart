import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_selectable_card/ui_selectable_card.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/repositories/models/occurrence_scope.dart';

/// Страница «К каким событиям применить изменения?» после «Сохранить изменения» у серии.
///
/// «Только {дата}» доступно, если из формы изменены лишь название, описание, тип и время
/// ([allowsOne]); иначе остаётся «{дата} и все следующие» с пояснением. [showResetHint] — у
/// выбранной области отмены дат, которых нет в новом расписании, сбросятся.
class EditScopePage extends StatelessWidget {
  const EditScopePage({
    required this.date,
    required this.scope,
    required this.allowsOne,
    required this.isLoading,
    required this.isSaving,
    required this.loadFailed,
    required this.showResetHint,
    required this.onScopeChanged,
    required this.onSave,
    required this.onDiscard,
    required this.onRetry,
    required this.onBack,
    super.key,
  });

  final DateTime date;
  final OccurrenceScope scope;
  final bool allowsOne;

  /// Сводка серии ещё грузится (по ней считается остаток и сброс отмен).
  final bool isLoading;
  final bool isSaving;
  final bool loadFailed;
  final bool showResetHint;
  final ValueChanged<OccurrenceScope> onScopeChanged;
  final VoidCallback onSave;

  /// «Не сохранять»: закрывает шторку без изменений.
  final VoidCallback onDiscard;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final dateText = DateFormat.MMMMd(l10n.localeName).format(date);
    final effective = allowsOne ? scope : OccurrenceScope.future;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => onBack(),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(UiSpacing.x5, 0, UiSpacing.x5, UiSpacing.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiSheetHeader.back(
              title: l10n.editScopeTitle,
              backLabel: l10n.eventDetailsBack,
              onCancel: onBack,
            ),
            const SizedBox(height: UiSpacing.x3),
            Text(l10n.editScopeQuestion, style: fonts.body.copyWith(color: palette.ink2)),
            const SizedBox(height: UiSpacing.x3),
            if (loadFailed) ...[
              Text(l10n.editScopeLoadFailed, style: fonts.body.copyWith(color: palette.danger)),
              const SizedBox(height: UiSpacing.x4),
              UiButton.secondary(label: l10n.eventActionRetry, onPressed: onRetry),
            ] else if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: UiSpacing.x8),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (allowsOne) ...[
                UiSelectableCard(
                  label: l10n.editScopeOne(dateText),
                  selected: effective == OccurrenceScope.one,
                  onTap: () => onScopeChanged(OccurrenceScope.one),
                ),
                const SizedBox(height: UiSpacing.x2),
              ],
              UiSelectableCard(
                label: l10n.editScopeFuture(dateText),
                selected: effective == OccurrenceScope.future,
                onTap: () => onScopeChanged(OccurrenceScope.future),
              ),
              if (!allowsOne) ...[
                const SizedBox(height: UiSpacing.x3),
                Text(
                  l10n.editScopeOneUnavailable,
                  style: fonts.footnote.copyWith(color: palette.ink2),
                ),
              ],
              const SizedBox(height: UiSpacing.x5),
              UiButton.main(label: l10n.editScopeSave, isLoading: isSaving, onPressed: onSave),
              if (showResetHint && effective == OccurrenceScope.future) ...[
                const SizedBox(height: UiSpacing.x3),
                Text(
                  l10n.editScopeResetHint,
                  textAlign: TextAlign.center,
                  style: fonts.footnote.copyWith(color: palette.ink2),
                ),
              ],
              const SizedBox(height: UiSpacing.x3),
              UiButton.secondary(
                label: l10n.editScopeDiscard,
                staticFillColor: palette.surface,
                staticItemColor: palette.ink,
                defaultBorderColor: palette.line,
                onPressed: isSaving ? null : onDiscard,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
