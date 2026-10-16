import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/schedule/core/data/enums/scheule_event_type_enum.dart';
import 'package:tails_mobile/src/feature/schedule/create_event/presentation/utils/event_type_options.dart';

/// Поле «Тип события» в форме: до выбора — «Выберите тип», после — иконка и название типа.
/// Нажатие открывает список типов.
class EventTypeField extends StatelessWidget {
  const EventTypeField({required this.selected, required this.onTap, super.key});

  final ScheduleEventTypeEnum? selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;
    final type = selected;
    final option = type == null ? null : eventTypeOptionOf(type);

    return UiCard(
      showShadow: false,
      showBorder: true,
      borderRadius: UiRadius.mdAll,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x3, vertical: UiSpacing.x2),
      child: Row(
        children: [
          UiIconBadge(
            icon: option?.icon ?? Icons.sell_outlined,
            size: 32,
            iconSize: 18,
            foregroundColor: option == null ? palette.ink2 : palette.accent,
            backgroundColor: option == null ? palette.sunken : palette.accentTint,
          ),
          const SizedBox(width: UiSpacing.x3),
          Expanded(
            child: Text(
              option?.titleOf(l10n) ?? l10n.createEventTypePlaceholder,
              style: context.uiFonts.body.copyWith(
                color: option == null ? palette.ink3 : palette.ink,
              ),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.ink3),
        ],
      ),
    );
  }
}
