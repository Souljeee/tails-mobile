import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

/// Круглый аватар питомца. Без фото или при ошибке загрузки показывает заглушку.
class UiPetAvatar extends StatelessWidget {
  const UiPetAvatar({
    required this.imageUrl,
    this.placeholderAsset,
    this.size = 40,
    this.borderColor,
    super.key,
  });

  final String? imageUrl;

  /// Путь к картинке-заглушке (по виду питомца). Без неё показывается иконка лапки.
  final String? placeholderAsset;
  final double size;

  /// Цвет тонкой обводки; по умолчанию без обводки.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final url = imageUrl;
    final placeholder = _AvatarPlaceholder(size: size, asset: placeholderAsset);

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderColor == null ? null : Border.all(color: borderColor!, width: 2),
        color: palette.sunken,
      ),
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: url == null || url.isEmpty
              ? placeholder
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => placeholder,
                  errorWidget: (_, _, _) => placeholder,
                ),
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({required this.size, this.asset});

  final double size;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final asset = this.asset;
    if (asset != null) {
      final cacheWidth = (size * MediaQuery.devicePixelRatioOf(context)).round();

      return Image.asset(asset, fit: BoxFit.cover, cacheWidth: cacheWidth);
    }

    return Center(
      child: Icon(Icons.pets, size: size * 0.5, color: context.uiPalette.ink3),
    );
  }
}
