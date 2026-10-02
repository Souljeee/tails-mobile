import 'package:flutter/cupertino.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Один барабан панели: подписи пунктов и выбранный индекс.
class UiWheelColumn {
  const UiWheelColumn({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    this.flex = 1,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int flex;
}

/// Встроенная панель с барабанами одного вида на обе платформы
/// («день + месяц», «дата», «время»).
class UiWheelPanel extends StatelessWidget {
  const UiWheelPanel({required this.columns, super.key});

  static const double height = 176;
  static const double itemExtent = 40;

  final List<UiWheelColumn> columns;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(color: palette.sunken, borderRadius: UiRadius.mdAll),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x2),
          child: Row(
            children: [
              for (final column in columns)
                Expanded(
                  flex: column.flex,
                  child: _Wheel(column: column),
                ),
            ],
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

  @override
  void didUpdateWidget(_Wheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final index = widget.column.selectedIndex;
    if (_controller.hasClients && _controller.selectedItem != index) {
      _controller.jumpToItem(index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final style = context.uiFonts.body.copyWith(color: palette.ink);

    return CupertinoPicker(
      scrollController: _controller,
      itemExtent: UiWheelPanel.itemExtent,
      selectionOverlay: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface.withValues(alpha: 0.5),
          borderRadius: UiRadius.smAll,
        ),
      ),
      onSelectedItemChanged: widget.column.onSelected,
      children: [
        for (final label in widget.column.labels)
          Center(child: Text(label, maxLines: 1, style: style)),
      ],
    );
  }
}
