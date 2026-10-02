import 'package:flutter/cupertino.dart' show CupertinoPicker;
import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Один барабан панели: подписи пунктов и выбранный индекс.
class UiWheelColumn {
  const UiWheelColumn({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.flex = 1,
    this.alignment = Alignment.center,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int flex;
  final AlignmentGeometry alignment;
}

/// Нижняя панель с барабанами («день + месяц», «дата», «время»), одинаковая на iOS и Android.
///
/// Шапка: слева необязательное действие ([leftLabel], например «Удалить» или «Отмена»), по центру
/// [title], справа [rightLabel] («Применить», «Добавить»). Панель рисуется на месте кнопки
/// «Сохранить» и учитывает нижнюю безопасную зону.
class UiWheelPanel extends StatelessWidget {
  const UiWheelPanel({
    required this.title,
    required this.rightLabel,
    required this.onRight,
    required this.columns,
    this.leftLabel,
    this.onLeft,
    this.leftIsDestructive = false,
    this.separator,
    super.key,
  });

  /// Число видимых строк барабана.
  static const int visibleRows = 5;
  static const double itemExtent = 40;

  final String title;
  final String rightLabel;
  final VoidCallback onRight;
  final String? leftLabel;
  final VoidCallback? onLeft;

  /// Левое действие опасное («Удалить») и рисуется цветом `danger`.
  final bool leftIsDestructive;
  final List<UiWheelColumn> columns;

  /// Символ между первым и вторым барабаном, например `:` для времени.
  final String? separator;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: UiRadius.xlTop),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: UiSizes.buttonL,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: leftLabel == null
                            ? null
                            : _PanelAction(
                                label: leftLabel!,
                                color: leftIsDestructive ? palette.danger : palette.accent,
                                onTap: onLeft,
                              ),
                      ),
                    ),
                    Text(title, style: fonts.bodySemibold.copyWith(color: palette.ink)),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _PanelAction(
                          label: rightLabel,
                          color: palette.accent,
                          bold: true,
                          onTap: onRight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: itemExtent * visibleRows,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
                      child: Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: palette.sunken,
                            borderRadius: UiRadius.smAll,
                          ),
                          child: const SizedBox(height: itemExtent, width: double.infinity),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x5),
                    child: Row(
                      children: [
                        for (var i = 0; i < columns.length; i++) ...[
                          if (i == 1 && separator != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x4),
                              child: Text(
                                separator!,
                                style: fonts.headline.copyWith(color: palette.ink),
                              ),
                            ),
                          Expanded(
                            flex: columns[i].flex,
                            child: _Wheel(column: columns[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiSpacing.x2),
          ],
        ),
      ),
    );
  }
}

class _PanelAction extends StatelessWidget {
  const _PanelAction({required this.label, required this.color, this.onTap, this.bold = false});

  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final fonts = context.uiFonts;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: label,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: UiSizes.minTapTarget),
          child: Align(
            widthFactor: 1,
            child: Text(label, style: (bold ? fonts.bodyBold : fonts.body).copyWith(color: color)),
          ),
        ),
      ),
    );
  }
}

class _Wheel extends StatefulWidget {
  const _Wheel({required this.column});

  final UiWheelColumn column;

  @override
  State<_Wheel> createState() => _WheelState();
}

class _WheelState extends State<_Wheel> {
  late final FixedExtentScrollController _controller = FixedExtentScrollController(
    initialItem: widget.column.selectedIndex,
  );

  /// Индекс под выделением во время прокрутки (для жирного шрифта выбранной строки).
  late int _current = widget.column.selectedIndex;

  @override
  void didUpdateWidget(_Wheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.column.selectedIndex;
    if (index != _current) {
      _current = index;
    }
    if (_controller.hasClients && _controller.selectedItem != index) {
      _controller.jumpToItem(index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(int index) {
    setState(() => _current = index);
    widget.column.onSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final labels = widget.column.labels;

    return CupertinoPicker(
      scrollController: _controller,
      itemExtent: UiWheelPanel.itemExtent,
      diameterRatio: 8,
      selectionOverlay: const SizedBox.shrink(),
      backgroundColor: const Color(0x00000000),
      onSelectedItemChanged: _onChanged,
      children: [
        for (var i = 0; i < labels.length; i++)
          Align(
            alignment: widget.column.alignment,
            child: Text(
              labels[i],
              maxLines: 1,
              style: i == _current
                  ? fonts.headline.copyWith(color: palette.ink)
                  : fonts.bodySemibold.copyWith(color: palette.ink3),
            ),
          ),
      ],
    );
  }
}
