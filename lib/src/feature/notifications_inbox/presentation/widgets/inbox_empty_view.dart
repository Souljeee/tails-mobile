import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_empty_state/ui_empty_state.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_text_link/ui_text_link.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

const double _tileSize = 72;
const double _tileIconSize = 32;

/// Уведомлений ещё не было: колокольчик и ссылка на настройки уведомлений.
class InboxEmptyView extends StatelessWidget {
  const InboxEmptyView({required this.onOpenSettings, super.key});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UiEmptyState(
            illustration: context.uiImages.emptyNotifications.image(),
            title: l10n.inboxEmptyTitle,
            message: l10n.inboxEmptyMessage,
          ),
          UiTextLink(label: l10n.inboxEmptyAction, onTap: onOpenSettings),
        ],
      ),
    );
  }
}

/// Во вкладке «Непрочитанные» ничего нет: всё прочитано.
class InboxAllReadView extends StatelessWidget {
  const InboxAllReadView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.uiPalette;

    return UiEmptyState(
      illustration: Center(
        child: UiIconBadge(
          icon: Icons.check,
          size: _tileSize,
          iconSize: _tileIconSize,
          foregroundColor: palette.pine,
          backgroundColor: palette.pineTint,
        ),
      ),
      title: l10n.inboxAllReadTitle,
      message: l10n.inboxAllReadMessage,
    );
  }
}
