import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Круг для выбора фото: пунктирный с камерой, пока фото нет, и с бейджем-действием.
///
/// Показывает переданное [image] (локальный файл или сетевое изображение) и подпись-кнопку
/// под кругом. Сам не знает, откуда фото: выбор источника — забота экрана через [onTap].
class UiPhotoPicker extends StatelessWidget {
  const UiPhotoPicker({
    required this.hasPhoto,
    required this.label,
    required this.onTap,
    this.image,
    this.hint,
    this.semanticLabel,
    this.size = 120,
    super.key,
  });

  final bool hasPhoto;

  /// Содержимое круга; игнорируется, пока [hasPhoto] равно `false`.
  final Widget? image;

  /// Подпись-кнопка под кругом: «Добавить фото» / «Изменить фото».
  final String label;

  /// Пояснение под подписью, показывается, пока фото нет.
  final String? hint;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: semanticLabel ?? label,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: onTap,
            child: SizedBox.square(
              dimension: size + UiSpacing.x2,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    foregroundPainter: hasPhoto ? null : UiDashedCirclePainter(palette.controlLine),
                    child: ClipOval(
                      child: SizedBox.square(
                        dimension: size,
                        child: ColoredBox(
                          color: palette.sunken,
                          child: hasPhoto && image != null
                              ? image
                              : Icon(Icons.photo_camera_outlined, size: 40, color: palette.ink3),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: UiSpacing.x1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: palette.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.canvas, width: 3),
                        boxShadow: UiShadows.e1,
                      ),
                      child: SizedBox.square(
                        dimension: 36,
                        child: Icon(
                          hasPhoto ? Icons.edit : Icons.add,
                          color: palette.surface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: UiSpacing.x3),
        Text(
          label,
          style: fonts.callout.copyWith(color: palette.accent, fontWeight: FontWeight.w700),
        ),
        if (!hasPhoto && hint != null) ...[
          const SizedBox(height: UiSpacing.x1),
          Text(
            hint!,
            textAlign: TextAlign.center,
            style: fonts.footnote.copyWith(color: palette.ink3),
          ),
        ],
      ],
    );
  }
}

/// Пунктирная окружность вокруг пустой области фото.
class UiDashedCirclePainter extends CustomPainter {
  const UiDashedCirclePainter(this.color);

  final Color color;

  static const double _dash = 6;
  static const double _gap = 5;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final radius = size.shortestSide / 2 - 1;
    final circumference = 2 * math.pi * radius;
    final count = (circumference / (_dash + _gap)).floor();
    final sweep = 2 * math.pi / count;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: radius);

    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, i * sweep, sweep * _dash / (_dash + _gap), false, paint);
    }
  }

  @override
  bool shouldRepaint(UiDashedCirclePainter oldDelegate) => oldDelegate.color != color;
}
