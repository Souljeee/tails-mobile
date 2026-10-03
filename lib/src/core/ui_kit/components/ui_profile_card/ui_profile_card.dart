import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_card/ui_card.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_user_avatar/ui_user_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Карточка пользователя в профиле: фото, имя, номер и подпись-действие.
///
/// Вся карточка ведёт к редактированию ([onTap]). Если фото нет, вместо него пунктирный
/// круг с камерой; нажатие на него вызывает [onAvatarTap] и сразу открывает выбор фото.
/// Если имя не указано, показывается серая подсказка [namePlaceholder].
class UiProfileCard extends StatelessWidget {
  const UiProfileCard({
    required this.name,
    required this.namePlaceholder,
    required this.caption,
    required this.onTap,
    this.phone,
    this.imageUrl,
    this.onAvatarTap,
    this.avatarSemanticLabel,
    this.isAvatarBusy = false,
    super.key,
  });

  static const double avatarSize = 72;

  final String? name;
  final String namePlaceholder;

  /// Уже отформатированный номер телефона.
  final String? phone;

  /// Подпись-действие под номером: «Редактировать профиль» или «Добавить фото».
  final String caption;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onAvatarTap;
  final String? avatarSemanticLabel;
  final bool isAvatarBusy;

  bool get _hasName => name != null && name!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final title = _hasName ? name!.trim() : namePlaceholder;

    return Semantics(
      container: true,
      child: UiCard(
        onTap: onTap,
        child: Row(
          children: [
            UiUserAvatar(
              imageUrl: imageUrl,
              size: avatarSize,
              invitesPhoto: true,
              isBusy: isAvatarBusy,
              onTap: onAvatarTap,
              semanticLabel: avatarSemanticLabel,
            ),
            const SizedBox(width: UiSpacing.x4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: fonts.headline.copyWith(color: _hasName ? palette.ink : palette.ink3),
                  ),
                  if (phone != null && phone!.isNotEmpty)
                    Text(phone!, style: fonts.monoMeta.copyWith(color: palette.ink2)),
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
