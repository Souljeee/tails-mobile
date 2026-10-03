import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_photo_picker/ui_photo_picker.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

/// Фото пользователя в круге.
///
/// Без фото показывает силуэт. С [invitesPhoto] вместо силуэта — пунктирный круг с камерой
/// и значком «+»: так видно, что фото можно добавить; нажатие вызывает [onTap].
/// [isBusy] накрывает фото индикатором загрузки.
class UiUserAvatar extends StatelessWidget {
  const UiUserAvatar({
    required this.imageUrl,
    this.size = 64,
    this.invitesPhoto = false,
    this.isBusy = false,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final String? imageUrl;
  final double size;
  final bool invitesPhoto;
  final bool isBusy;
  final VoidCallback? onTap;

  /// Подпись для скринридера у нажимаемого аватара.
  final String? semanticLabel;

  bool get _hasPhoto => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final showInvite = invitesPhoto && !_hasPhoto;

    final placeholder = Center(
      child: Icon(
        showInvite ? Icons.photo_camera_outlined : Icons.person_outline,
        size: size * (showInvite ? 0.38 : 0.5),
        color: palette.ink3,
      ),
    );

    Widget avatar = DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, color: palette.sunken),
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!_hasPhoto)
                placeholder
              else
                CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => placeholder,
                  errorWidget: (_, _, _) => placeholder,
                ),
              if (isBusy)
                ColoredBox(
                  color: palette.surface.withValues(alpha: 0.6),
                  child: Center(
                    child: SizedBox.square(
                      dimension: size * 0.3,
                      child: CircularProgressIndicator(strokeWidth: 2, color: palette.accent),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (showInvite) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(foregroundPainter: UiDashedCirclePainter(palette.controlLine), child: avatar),
          Positioned(
            right: -2,
            bottom: -2,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: palette.accent,
                shape: BoxShape.circle,
                border: Border.all(color: palette.surface, width: 2),
              ),
              child: SizedBox.square(
                dimension: size * 0.36,
                child: Icon(Icons.add, size: size * 0.24, color: palette.surface),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap == null) {
      return avatar;
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: avatar),
    );
  }
}
