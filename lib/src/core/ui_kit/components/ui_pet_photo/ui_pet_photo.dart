import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

/// Большое фото питомца на всю доступную площадь. Без фото или при ошибке загрузки
/// показывает картинку-заглушку [placeholderAsset], а если её нет — иконку лапки.
class UiPetPhoto extends StatelessWidget {
  const UiPetPhoto({
    required this.imageUrl,
    this.placeholderAsset,
    this.iconSize = 48,
    super.key,
  });

  final String? imageUrl;

  /// Путь к картинке-заглушке (по виду питомца).
  final String? placeholderAsset;

  /// Размер иконки лапки, если заглушки-картинки нет.
  final double iconSize;

  /// Ширина декодирования заглушки: исходник крупный, а на экране нужна лишь ширина телефона.
  static const int _placeholderCacheWidth = 1000;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final url = imageUrl;

    Widget fallback() {
      final asset = placeholderAsset;
      if (asset != null) {
        return Image.asset(
          asset,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: _placeholderCacheWidth,
        );
      }

      return ColoredBox(
        color: palette.sunken,
        child: Icon(Icons.pets, size: iconSize, color: palette.ink3),
      );
    }

    if (url == null || url.isEmpty) return fallback();

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => ColoredBox(color: palette.sunken),
      errorWidget: (context, url, error) => fallback(),
    );
  }
}
