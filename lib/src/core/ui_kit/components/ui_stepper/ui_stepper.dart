import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_sizes.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

/// Счётчик в таблетке «− значение +» с границами [min]..[max].
///
/// [editable] — число можно набрать с цифровой клавиатуры: больше [max] заменяется на [max],
/// пустое и меньше [min] — на [min] после окончания ввода.
class UiStepper extends StatelessWidget {
  const UiStepper({
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
    this.decrementLabel,
    this.incrementLabel,
    this.editable = false,
    this.valueLabel,
    super.key,
  });

  /// Минимальная ширина значения: число не «пляшет» при смене разрядности.
  static const double valueWidth = 32;

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  /// Подписи кнопок для скринридера.
  final String? decrementLabel;
  final String? incrementLabel;

  /// Число можно ввести с клавиатуры.
  final bool editable;

  /// Подпись поля ввода для скринридера (при [editable]).
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return DecoratedBox(
      decoration: BoxDecoration(color: palette.sunken, borderRadius: UiRadius.fullAll),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            label: decrementLabel,
            onTap: value > min ? () => onChanged(value - 1) : null,
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: valueWidth),
            child: editable
                ? _EditableValue(
                    value: value,
                    min: min,
                    max: max,
                    label: valueLabel,
                    onChanged: onChanged,
                  )
                : Text(
                    '$value',
                    textAlign: TextAlign.center,
                    style: context.uiFonts.bodyBold.copyWith(color: palette.ink),
                  ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            label: incrementLabel,
            onTap: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap, this.label});

  final IconData icon;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final enabled = onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: UiRadius.fullAll,
        splashFactory: NoSplash.splashFactory,
        child: SizedBox.square(
          dimension: UiSizes.minTapTarget,
          child: Padding(
            padding: const EdgeInsets.all(UiSpacing.x2),
            child: Icon(icon, color: enabled ? palette.ink : palette.ink3),
          ),
        ),
      ),
    );
  }
}

/// Число, которое можно набрать с клавиатуры.
class _EditableValue extends StatefulWidget {
  const _EditableValue({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.label,
  });

  final int value;
  final int min;
  final int max;
  final String? label;
  final ValueChanged<int> onChanged;

  @override
  State<_EditableValue> createState() => _EditableValueState();
}

class _EditableValueState extends State<_EditableValue> {
  late final TextEditingController _controller = TextEditingController(text: '${widget.value}');
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _EditableValue oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Значение поменяли кнопки или смена границ: показываем его, если пользователь не набирает
    // то же самое число.
    if (int.tryParse(_controller.text) != widget.value &&
        !(_focusNode.hasFocus && _controller.text.isEmpty)) {
      _setText('${widget.value}');
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _setText(String text) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _onChanged(String text) {
    final parsed = int.tryParse(text);
    if (parsed == null) {
      return;
    }
    if (parsed > widget.max) {
      _setText('${widget.max}');
      widget.onChanged(widget.max);

      return;
    }
    if (parsed >= widget.min) {
      widget.onChanged(parsed);
    }
  }

  /// Ввод закончен: пустое и ноль становятся минимумом.
  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      return;
    }
    final parsed = int.tryParse(_controller.text);
    if (parsed == null || parsed < widget.min) {
      _setText('${widget.min}');
      widget.onChanged(widget.min);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    return Semantics(
      label: widget.label,
      child: SizedBox(
        width: UiStepper.valueWidth + UiSpacing.x2,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter('${widget.max}'.length),
          ],
          style: context.uiFonts.bodyBold.copyWith(color: palette.ink),
          cursorColor: palette.accent,
          decoration: const InputDecoration.collapsed(hintText: null),
          onChanged: _onChanged,
          onTapOutside: (_) => _focusNode.unfocus(),
          onSubmitted: (_) => _focusNode.unfocus(),
        ),
      ),
    );
  }
}
