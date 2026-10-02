import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/recurrence/domain/recurrence_draft.dart';

/// «В 17:05 — время из события» под настройками недели, месяца и года.
///
/// Для события «весь день» (времени нет) ничего не показывает.
class RecurrenceTimeHint extends StatelessWidget {
  const RecurrenceTimeHint({required this.draft, super.key});

  final RecurrenceDraft draft;

  @override
  Widget build(BuildContext context) {
    final time = draft.eventTime;
    if (time == null) {
      return const SizedBox.shrink();
    }
    final palette = context.uiPalette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpacing.x1, UiSpacing.x3, UiSpacing.x1, 0),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: palette.ink3),
          const SizedBox(width: UiSpacing.x2),
          Expanded(
            child: Text(
              context.l10n.recurrenceTimeFromEvent(time.format()),
              style: context.uiFonts.footnote.copyWith(color: palette.ink2),
            ),
          ),
        ],
      ),
    );
  }
}
