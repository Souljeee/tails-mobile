import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/colors/ui_palette.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_icon_badge/ui_icon_badge.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Цвет плитки с иконкой в [UiNavRow].
enum UiNavRowTone { neutral, accent, amber, pine, danger }

/// Строка меню «плитка с иконкой — заголовок и подпись — значение — шеврон или переключатель»
/// (RNavRow в дизайн-системе). Лежит внутри `UiGroupedList`.
///
/// Нажимается вся строка. Правая часть: [trailing], иначе переключатель у [UiNavRow.toggle],
/// иначе шеврон, если задан [onTap].
class UiNavRow extends StatelessWidget {
  const UiNavRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.tone = UiNavRowTone.neutral,
    this.trailing,
    this.onTap,
    this.enabled = true,
    super.key,
  }) : switchValue = null,
       onSwitchChanged = null;

  /// Строка с переключателем вместо шеврона; нажатие по строке тоже переключает.
  const UiNavRow.toggle({
    required this.icon,
    required this.title,
    required bool isOn,
    required ValueChanged<bool>? onChanged,
    this.subtitle,
    this.tone = UiNavRowTone.neutral,
    this.enabled = true,
    super.key,
  }) : switchValue = isOn,
       onSwitchChanged = onChanged,
       value = null,
       trailing = null,
       onTap = null;

  /// Размер плитки с иконкой.
  static const double badgeSize = 36;

  /// Ширина плитки и отступа до текста, для `UiGroupedList.dividerIndent`.
  static const double leadingWidth = badgeSize + UiSpacing.x3;

  /// Максимальная ширина значения справа; длиннее обрезается многоточием.
  static const double valueMaxWidth = 160;

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Значение справа от заголовка, например «Включены».
  final String? value;
  final UiNavRowTone tone;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Неактивная строка: приглушена и не нажимается.
  final bool enabled;

  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  bool get _isToggle => switchValue != null;

  VoidCallback? get _effectiveTap {
    if (!enabled) {
      return null;
    }

    if (_isToggle) {
      final onChanged = onSwitchChanged;

      return onChanged == null ? null : () => onChanged(!switchValue!);
    }

    return onTap;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final colors = _UiNavRowColors.of(palette, tone);
    final tap = _effectiveTap;
    final dimmed = !enabled;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: UiSizes.buttonL),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: UiSpacing.x2),
        child: Row(
          children: [
            UiIconBadge(
              icon: icon,
              size: badgeSize,
              iconSize: 18,
              foregroundColor: colors.icon,
              backgroundColor: colors.tile,
            ),
            const SizedBox(width: UiSpacing.x3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: fonts.bodySemibold.copyWith(color: colors.title)),
                  if (subtitle != null)
                    Text(subtitle!, style: fonts.footnote.copyWith(color: palette.ink3)),
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: UiSpacing.x2),
              // Значение не делит место с заголовком поровну: оно занимает своё содержимое
              // (не шире valueMaxWidth), остальное отдаётся заголовку.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: valueMaxWidth),
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: fonts.body.copyWith(color: palette.ink3),
                ),
              ),
            ],
            if (_isToggle) ...[
              const SizedBox(width: UiSpacing.x3),
              ExcludeSemantics(
                child: _RowSwitch(value: switchValue!, onChanged: _toggleHandler),
              ),
            ] else if (trailing != null) ...[
              const SizedBox(width: UiSpacing.x2),
              trailing!,
            ] else if (onTap != null) ...[
              const SizedBox(width: UiSpacing.x1),
              Icon(Icons.chevron_right, size: 22, color: palette.ink3),
            ],
          ],
        ),
      ),
    );

    final content = Opacity(opacity: dimmed ? 0.5 : 1, child: row);

    if (_isToggle) {
      return Semantics(
        toggled: switchValue,
        enabled: enabled,
        label: title,
        onTap: tap,
        excludeSemantics: true,
        child: InkWell(onTap: tap, splashFactory: NoSplash.splashFactory, child: content),
      );
    }

    if (tap == null) {
      return content;
    }

    return Semantics(
      button: true,
      child: InkWell(onTap: tap, splashFactory: NoSplash.splashFactory, child: content),
    );
  }

  ValueChanged<bool>? get _toggleHandler => enabled ? onSwitchChanged : null;
}

class _RowSwitch extends StatelessWidget {
  const _RowSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Switch(
      value: value,
      onChanged: onChanged,
      thumbColor: WidgetStatePropertyAll(palette.surface),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? palette.accent : palette.sunken,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? palette.accent : palette.controlLine,
      ),
    );
  }
}

class _UiNavRowColors {
  const _UiNavRowColors({required this.tile, required this.icon, required this.title});

  final Color tile;
  final Color icon;
  final Color title;

  factory _UiNavRowColors.of(UiPalette palette, UiNavRowTone tone) => switch (tone) {
    UiNavRowTone.neutral => _UiNavRowColors(
      tile: palette.sunken,
      icon: palette.ink2,
      title: palette.ink,
    ),
    UiNavRowTone.accent => _UiNavRowColors(
      tile: palette.accentTint,
      icon: palette.accent,
      title: palette.ink,
    ),
    UiNavRowTone.amber => _UiNavRowColors(
      tile: palette.amberTint,
      icon: palette.amber,
      title: palette.ink,
    ),
    UiNavRowTone.pine => _UiNavRowColors(
      tile: palette.pineTint,
      icon: palette.pine,
      title: palette.ink,
    ),
    UiNavRowTone.danger => _UiNavRowColors(
      tile: palette.dangerTint,
      icon: palette.danger,
      title: palette.danger,
    ),
  };
}
