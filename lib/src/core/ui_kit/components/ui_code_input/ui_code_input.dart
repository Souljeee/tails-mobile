import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

/// Поле ввода цифрового кода из нескольких ячеек (по одной цифре в каждой).
///
/// Фокус переходит между ячейками сам; [onCompleted] вызывается, когда заполнена
/// последняя, [onChanged] — при любом изменении с текущим значением кода.
class UiCodeInput extends StatefulWidget {
  const UiCodeInput({
    this.onCompleted,
    this.onChanged,
    this.length = 4,
    this.hasError = false,
    this.enabled = true,
    super.key,
  });

  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final int length;

  /// Подсвечивает ячейки как ошибочные.
  final bool hasError;
  final bool enabled;

  @override
  State<UiCodeInput> createState() => _UiCodeInputState();
}

class _UiCodeInputState extends State<UiCodeInput> {
  late final _controllers = List.generate(widget.length, (_) => TextEditingController());
  late final _focusNodes = List.generate(widget.length, (_) => FocusNode());

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }

    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  String get _code => _controllers.map((e) => e.text).join();

  void _goNext(int i) {
    if (i < widget.length - 1) {
      _focusNodes[i + 1].requestFocus();
    } else {
      _focusNodes[i].unfocus();
      if (_code.length == widget.length) widget.onCompleted?.call(_code);
    }
  }

  void _goPrev(int i) {
    if (i > 0) {
      _focusNodes[i - 1].requestFocus();
    } else {
      _focusNodes[i].unfocus();
    }
  }

  void _onChanged(int i, String v) {
    _handleChange(i, v);

    widget.onChanged?.call(_code);
  }

  void _handleChange(int i, String v) {
    final digitsOnly = v.replaceAll(RegExp('[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      _controllers[i].text = '';

      _goPrev(i);

      return;
    }

    final ch = digitsOnly.characters.last;

    if (_controllers[i].text != ch) {
      _controllers[i].text = ch;

      _controllers[i].selection = const TextSelection.collapsed(offset: 1);
    }

    _goNext(i);
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (event) {
        for (final focusNode in _focusNodes) {
          focusNode.unfocus();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (fieldIndex) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpacing.x2),
            child: _CodeCell(
              controller: _controllers[fieldIndex],
              focusNode: _focusNodes[fieldIndex],
              hasError: widget.hasError,
              enabled: widget.enabled,
              semanticLabel: context.l10n.enterCodeDigitLabel(fieldIndex + 1, widget.length),
              textInputAction: fieldIndex == widget.length - 1
                  ? TextInputAction.done
                  : TextInputAction.next,
              onChanged: (value) => _onChanged(fieldIndex, value),
              onSubmitted: (_) {
                if (fieldIndex == widget.length - 1) FocusScope.of(context).unfocus();
              },
            ),
          );
        }),
      ),
    );
  }
}

/// Ячейка ввода одной цифры кода: обводка и кольцо фокуса как у `UiTextField`.
class _CodeCell extends StatelessWidget {
  const _CodeCell({
    required this.controller,
    required this.focusNode,
    required this.semanticLabel,
    required this.hasError,
    required this.enabled,
    required this.textInputAction,
    required this.onChanged,
    required this.onSubmitted,
  });

  static const double _size = 64;

  final TextEditingController controller;
  final FocusNode focusNode;
  final String semanticLabel;
  final bool hasError;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: UiRadius.mdAll,
      borderSide: BorderSide(color: color, width: width),
    );

    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: UiRadius.mdAll,
            boxShadow: focusNode.hasFocus
                ? [BoxShadow(color: palette.accentTint, spreadRadius: 4)]
                : null,
          ),
          child: child,
        );
      },
      child: SizedBox.square(
        dimension: _size,
        child: Semantics(
          label: semanticLabel,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: textInputAction,
            maxLength: 1,
            style: context.uiFonts.monoDigits.copyWith(
              color: palette.ink,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
            cursorColor: palette.accent,
            decoration: InputDecoration(
              filled: true,
              fillColor: palette.surface,
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: border(hasError ? palette.danger : palette.controlLine, 1),
              enabledBorder: border(hasError ? palette.danger : palette.controlLine, 1),
              focusedBorder: border(palette.accent, 2),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
      ),
    );
  }
}
