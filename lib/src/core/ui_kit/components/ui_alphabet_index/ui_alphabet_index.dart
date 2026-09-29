import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

/// Вертикальный алфавитный указатель: нажатие или скольжение пальцем выбирает букву.
class UiAlphabetIndex extends StatefulWidget {
  const UiAlphabetIndex({required this.letters, required this.onLetterSelected, super.key});

  final List<String> letters;
  final ValueChanged<String> onLetterSelected;

  @override
  State<UiAlphabetIndex> createState() => _UiAlphabetIndexState();
}

class _UiAlphabetIndexState extends State<UiAlphabetIndex> {
  static const double _itemHeight = 18;
  static const double _width = 24;

  int? _lastIndex;

  void _select(double dy) {
    if (widget.letters.isEmpty) {
      return;
    }

    final index = (dy / _itemHeight).floor().clamp(0, widget.letters.length - 1);

    if (index != _lastIndex) {
      _lastIndex = index;
      widget.onLetterSelected(widget.letters[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = context.uiFonts.monoEyebrow.copyWith(
      color: context.uiPalette.accent,
      fontSize: 11,
      letterSpacing: 0,
    );

    return ExcludeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) => _select(details.localPosition.dy),
        onVerticalDragUpdate: (details) => _select(details.localPosition.dy),
        onTapUp: (_) => _lastIndex = null,
        onVerticalDragEnd: (_) => _lastIndex = null,
        onTapCancel: () => _lastIndex = null,
        child: SizedBox(
          width: _width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final letter in widget.letters)
                SizedBox(
                  height: _itemHeight,
                  child: Center(child: Text(letter, style: style)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
