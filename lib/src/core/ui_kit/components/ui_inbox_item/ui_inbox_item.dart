import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_pet_avatar/ui_pet_avatar.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

/// Строка уведомления в списке «Центра уведомлений» (`RInboxItem` в макетах).
///
/// Нажимается вся строка. Непрочитанное отличается тремя признаками сразу: жирный заголовок,
/// точка акцента справа и время цветом акцента; фон не закрашивается. Рассчитана на размещение
/// в карточке без внутренних отступов: подсветка нажатия занимает всю ширину строки.
class UiInboxItem extends StatelessWidget {
  const UiInboxItem({
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.isRead,
    required this.leading,
    this.onTap,
    super.key,
  });

  /// Минимальная высота строки с одной строкой текста; с двумя строками она растёт до 96 pt.
  static const double minHeight = 76;

  /// Размер [leading] — аватара или плитки с иконкой.
  static const double leadingSize = 40;

  /// Отступ от левого края строки до текста: для разделителей между строками.
  static const double textInset = UiSpacing.x4 + leadingSize + UiSpacing.x3;

  static const int _maxTextLines = 2;
  static const double _dotSize = 8;

  final String title;
  final String body;

  /// Готовая подпись времени: «5 мин», «18:40», «28 сент.».
  final String timeLabel;
  final bool isRead;

  /// Аватар питомца ([UiInboxPetAvatar]) или плитка с иконкой (`UiIconBadge`) размером [leadingSize].
  final Widget leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final unreadPrefix = isRead ? '' : '${context.l10n.inboxItemNewSemantics}. ';

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$unreadPrefix$title. $body. $timeLabel',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashFactory: NoSplash.splashFactory,
          highlightColor: palette.sunken.withValues(alpha: 0.6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4, vertical: UiSpacing.x3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox.square(dimension: leadingSize, child: leading),
                  const SizedBox(width: UiSpacing.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: _maxTextLines,
                          overflow: TextOverflow.ellipsis,
                          style: (isRead ? fonts.body : fonts.bodyBold).copyWith(
                            color: palette.ink,
                          ),
                        ),
                        Text(
                          body,
                          maxLines: _maxTextLines,
                          overflow: TextOverflow.ellipsis,
                          style: fonts.footnote.copyWith(color: palette.ink2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: UiSpacing.x2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeLabel,
                        maxLines: 1,
                        style: fonts.monoMeta.copyWith(
                          color: isRead ? palette.ink3 : palette.accent,
                        ),
                      ),
                      if (!isRead) ...[
                        const SizedBox(height: UiSpacing.x3),
                        DecoratedBox(
                          decoration: BoxDecoration(color: palette.accent, shape: BoxShape.circle),
                          child: const SizedBox.square(dimension: _dotSize),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Аватар питомца для [UiInboxItem]: кольцо цвета питомца и значок типа события в углу.
class UiInboxPetAvatar extends StatelessWidget {
  const UiInboxPetAvatar({
    required this.imageUrl,
    required this.ringColor,
    required this.typeIcon,
    this.placeholderAsset,
    super.key,
  });

  final String? imageUrl;

  /// Путь к картинке-заглушке питомца без фото.
  final String? placeholderAsset;

  /// Цвет питомца (`UiPalette.petColor`).
  final Color ringColor;

  /// Значок типа события: таблетка, прививка, миска, прогулка.
  final IconData typeIcon;

  static const double _ringWidth = 2;
  static const double _badgeSize = 18;
  static const double _badgeIconSize = 11;
  static const double _badgeOverhang = 3;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        UiPetAvatar(
          imageUrl: imageUrl,
          placeholderAsset: placeholderAsset,
          size: UiInboxItem.leadingSize - _ringWidth * 2,
          borderColor: ringColor,
        ),
        Positioned(
          right: -_badgeOverhang,
          bottom: -_badgeOverhang,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surface,
              shape: BoxShape.circle,
              border: Border.all(color: palette.line),
            ),
            child: SizedBox.square(
              dimension: _badgeSize,
              child: Icon(typeIcon, size: _badgeIconSize, color: palette.ink),
            ),
          ),
        ),
      ],
    );
  }
}
