import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_checkbox/ui_checkbox.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Состояние вхождения на карточке.
enum UiEventTileStatus {
  scheduled,
  done,
  cancelled;

  bool get isDone => this == done;
  bool get isCancelled => this == cancelled;
}

/// Карточка события: цветная полоса питомца, аватар, название, тип и отметка выполнения.
///
/// Две независимые зоны нажатия: кружок справа с тонким разделителем ([onToggle]) и вся остальная
/// карточка ([onTap], открывает детали). У отменённого вхождения кружка нет: на его месте метка
/// [cancelledLabel], рамка пунктирная, текст и аватар приглушены.
class UiEventTile extends StatelessWidget {
  const UiEventTile({
    required this.title,
    required this.subtitle,
    required this.stripeColor,
    required this.leading,
    required this.status,
    required this.onToggle,
    this.onTap,
    this.typeIcon,
    this.isRecurring = false,
    this.cancelledLabel,
    this.toggleLabel,
    this.detailsLabel,
    super.key,
  });

  final String title;

  /// Например «Лекарства · Мистерио».
  final String subtitle;

  /// Цвет питомца.
  final Color stripeColor;

  /// Аватар питомца.
  final Widget leading;
  final UiEventTileStatus status;

  /// Нажатие на кружок: выполнить или снять отметку.
  final VoidCallback? onToggle;

  /// Нажатие на остальную карточку: открыть детали.
  final VoidCallback? onTap;

  /// Иконка типа события перед [subtitle].
  final IconData? typeIcon;

  /// Вхождение серии: после подписи показывается значок повтора.
  final bool isRecurring;

  /// Метка отменённого вхождения («Отменено»).
  final String? cancelledLabel;

  /// Подпись кружка для скринридера («Отметить выполненным» / «Снять отметку»).
  final String? toggleLabel;

  /// Подпись основной зоны для скринридера («Открыть детали»).
  final String? detailsLabel;

  static const double _toggleZoneWidth = 48;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final isDone = status.isDone;
    final isCancelled = status.isCancelled;
    final muted = isDone || isCancelled;

    final content = Row(
      children: [
        Opacity(opacity: isCancelled ? 0.5 : 1, child: leading),
        const SizedBox(width: UiSpacing.x3),
        Expanded(
          child: _TileTexts(
            title: title,
            subtitle: subtitle,
            typeIcon: typeIcon,
            isRecurring: isRecurring,
            isDone: isDone,
            muted: muted,
          ),
        ),
      ],
    );

    final body = InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(UiSpacing.x3, UiSpacing.x3, UiSpacing.x2, UiSpacing.x3),
        child: content,
      ),
    );

    return Semantics(
      container: true,
      child: AnimatedContainer(
        duration: UiMotion.base,
        curve: UiMotion.curve,
        decoration: BoxDecoration(
          color: isCancelled ? Colors.transparent : (isDone ? palette.sunken : palette.surface),
          borderRadius: UiRadius.mdAll,
          boxShadow: muted ? null : UiShadows.e1,
        ),
        foregroundDecoration: isCancelled ? _DashedBorder(palette.line) : null,
        child: ClipRRect(
          borderRadius: UiRadius.mdAll,
          child: Material(
            type: MaterialType.transparency,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: UiSpacing.x1,
                    child: ColoredBox(color: isCancelled ? palette.line : stripeColor),
                  ),
                  Expanded(
                    child: Semantics(button: onTap != null, label: detailsLabel, child: body),
                  ),
                  if (isCancelled)
                    _CancelledMark(label: cancelledLabel)
                  else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: UiSpacing.x3),
                      child: VerticalDivider(width: 1, thickness: 1, color: palette.line),
                    ),
                    SizedBox(
                      width: _toggleZoneWidth,
                      child: Center(
                        child: UiCheckbox(
                          isChecked: isDone,
                          onTap: onToggle,
                          accentOutline: true,
                          semanticsLabel: toggleLabel,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Метка справа у отменённого вхождения; без текста остаётся только отступ.
class _CancelledMark extends StatelessWidget {
  const _CancelledMark({required this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final text = label;
    if (text == null) {
      return const SizedBox(width: UiSpacing.x3);
    }

    return Padding(
      padding: const EdgeInsets.only(right: UiSpacing.x3),
      child: Center(
        child: Text(text, style: context.uiFonts.footnote.copyWith(color: context.uiPalette.ink3)),
      ),
    );
  }
}

/// Название, тип и подпись карточки.
class _TileTexts extends StatelessWidget {
  const _TileTexts({
    required this.title,
    required this.subtitle,
    required this.typeIcon,
    required this.isRecurring,
    required this.isDone,
    required this.muted,
  });

  final String title;
  final String subtitle;
  final IconData? typeIcon;
  final bool isRecurring;
  final bool isDone;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: UiMotion.base,
          style: fonts.bodyBold.copyWith(
            color: muted ? palette.ink3 : palette.ink,
            decoration: isDone ? TextDecoration.lineThrough : null,
          ),
          child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (typeIcon != null) ...[
              Icon(typeIcon, size: 14, color: palette.ink3),
              const SizedBox(width: UiSpacing.x1),
            ],
            Flexible(
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: fonts.footnote.copyWith(color: muted ? palette.ink3 : palette.ink2),
              ),
            ),
            if (isRecurring) ...[
              const SizedBox(width: UiSpacing.x1),
              Icon(Icons.repeat_rounded, size: 14, color: palette.ink3),
            ],
          ],
        ),
      ],
    );
  }
}

/// Пунктирная рамка со скруглением карточки.
class _DashedBorder extends Decoration {
  const _DashedBorder(this.color);

  final Color color;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _DashedBorderPainter(color);
}

class _DashedBorderPainter extends BoxPainter {
  _DashedBorderPainter(this.color);

  final Color color;

  static const double _dash = 6;
  static const double _gap = 4;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final size = configuration.size;
    if (size == null) {
      return;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      (offset & size).deflate(0.75),
      const Radius.circular(UiRadius.md),
    );

    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + _dash), paint);
        distance += _dash + _gap;
      }
    }
  }
}
