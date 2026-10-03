import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

/// Круглый аватар пользователя. Без фото или при ошибке загрузки показывает силуэт.
class UiUserAvatar extends StatelessWidget {
  const UiUserAvatar({required this.imageUrl, this.size = 64, super.key});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final url = imageUrl;
    final placeholder = Center(
      child: Icon(Icons.person_outline, size: size * 0.5, color: palette.ink3),
    );

    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, color: palette.sunken),
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
