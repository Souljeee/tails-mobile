import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_inbox_item/ui_inbox_item.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_section_header/ui_section_header.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/enums_extension.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/data/repositories/models/inbox_item.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/inbox_sections.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/inbox_time_format.dart';
import 'package:tails_mobile/src/feature/pets/core/data/repositories/models/pet_model.dart';

/// Группа уведомлений: заголовок («Сегодня», «Август») и карточка со строками.
class InboxSectionView extends StatelessWidget {
  const InboxSectionView({
    required this.section,
    required this.pets,
    required this.now,
    required this.onItemOpened,
    super.key,
  });

  final InboxSection section;

  /// Питомцы по id для аватаров.
  final Map<int, PetModel> pets;

  /// Момент, от которого считаются подписи времени.
  final DateTime now;
  final ValueChanged<InboxItem> onItemOpened;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpacing.x5, UiSpacing.x4, UiSpacing.x5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiSectionHeader(title: _title(context)),
          const SizedBox(height: UiSpacing.x2),
          UiCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: UiRadius.lgAll,
              child: Column(
                children: [
                  for (var i = 0; i < section.items.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: context.uiPalette.line,
                        indent: UiInboxItem.textInset,
                      ),
                    _InboxRow(
                      item: section.items[i],
                      pet: pets[section.items[i].petId],
                      now: now,
                      onOpened: onItemOpened,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    final l10n = context.l10n;

    return switch (section.type) {
      InboxSectionType.today => l10n.inboxSectionToday,
      InboxSectionType.yesterday => l10n.inboxSectionYesterday,
      InboxSectionType.earlier => l10n.inboxSectionEarlier,
      InboxSectionType.month => formatInboxMonth(section.month!, now, l10n.localeName),
    };
  }
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({
    required this.item,
    required this.pet,
    required this.now,
    required this.onOpened,
  });

  final InboxItem item;
  final PetModel? pet;
  final DateTime now;
  final ValueChanged<InboxItem> onOpened;

  @override
  Widget build(BuildContext context) {
    return UiInboxItem(
      title: item.title,
      body: item.body,
      timeLabel: formatInboxTime(context.l10n, item.createdAt, now),
      isRead: item.isRead,
      leading: _Leading(item: item, pet: pet),
      onTap: () => onOpened(item),
    );
  }
}

class _Leading extends StatelessWidget {
  const _Leading({required this.item, required this.pet});

  final InboxItem item;
  final PetModel? pet;

  @override
  Widget build(BuildContext context) {
    final pet = this.pet;
    final eventIcon = item.eventType?.icon;

    // Без питомца (объявление, питомец удалён или не загрузился) — плитка с иконкой.
    if (pet == null) {
      return UiIconBadge(icon: eventIcon ?? Icons.campaign_outlined);
    }

    return UiInboxPetAvatar(
      imageUrl: pet.image,
      ringColor: context.uiPalette.petColor(pet.colorIndex),
      typeIcon: eventIcon ?? Icons.pets,
    );
  }
}
