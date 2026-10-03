import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_user_avatar/ui_user_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Карточка пользователя на вкладке «Профиль» (RProfileCard): аватар, имя и подпись-действие.
///
/// Если имени нет, вместо него серым показывается [namePlaceholder].
class UiProfileCard extends StatelessWidget {
  const UiProfileCard({
    required this.name,
    required this.namePlaceholder,
    required this.caption,
    required this.onTap,
    this.imageUrl,
    super.key,
  });

  /// Имя пользователя; пустая строка и `null` считаются «имени нет».
  final String? name;
  final String namePlaceholder;

  /// Подпись под именем, например «Редактировать профиль».
  final String caption;
  final String? imageUrl;
  final VoidCallback? onTap;

  bool get _hasName => name != null && name!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Semantics(
      button: true,
      label: _hasName ? '${name!.trim()}. $caption' : '$namePlaceholder. $caption',
      excludeSemantics: true,
      child: UiCard(
        onTap: onTap,
        child: Row(
          children: [
            UiUserAvatar(imageUrl: imageUrl),
            const SizedBox(width: UiSpacing.x4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasName ? name!.trim() : namePlaceholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: fonts.headline.copyWith(color: _hasName ? palette.ink : palette.ink3),
                  ),
                  const SizedBox(height: UiSpacing.x1),
                  Text(
                    caption,
                    style: fonts.callout.copyWith(
                      color: palette.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 22, color: palette.ink3),
          ],
        ),
      ),
    );
  }
}
