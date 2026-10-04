import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_chip/ui_chip.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_text_link/ui_text_link.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/notifications_inbox/domain/notifications_inbox_bloc.dart';

/// Фильтры «Все» / «Непрочитанные · N» и действие «Прочитать все».
class InboxFilterBar extends StatelessWidget {
  const InboxFilterBar({
    required this.filter,
    required this.unreadCount,
    required this.onFilterChanged,
    required this.onReadAll,
    super.key,
  });

  final NotificationsInboxFilter filter;
  final int unreadCount;
  final ValueChanged<NotificationsInboxFilter> onFilterChanged;
  final VoidCallback onReadAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpacing.x5, UiSpacing.x2, UiSpacing.x5, UiSpacing.x2),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                UiChip(
                  label: l10n.inboxFilterAll,
                  selected: filter == NotificationsInboxFilter.all,
                  onTap: () => onFilterChanged(NotificationsInboxFilter.all),
                ),
                const SizedBox(width: UiSpacing.x2),
                Flexible(
                  child: UiChip(
                    label: unreadCount > 0
                        ? l10n.inboxFilterUnreadCount(unreadCount)
                        : l10n.inboxFilterUnread,
                    selected: filter == NotificationsInboxFilter.unread,
                    onTap: () => onFilterChanged(NotificationsInboxFilter.unread),
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0) ...[
            const SizedBox(width: UiSpacing.x3),
            UiTextLink(label: l10n.inboxReadAll, onTap: onReadAll),
          ],
        ],
      ),
    );
  }
}
