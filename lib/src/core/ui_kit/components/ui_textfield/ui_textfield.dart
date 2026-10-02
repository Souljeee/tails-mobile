import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tails_mobile/src/core/ui_kit/colors/ui_palette.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_form_field/ui_form_field.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_validators.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';

class UiTextField extends StatefulWidget {
  const UiTextField({
    required this.controller,
    this.enabled,
    this.autofocus = false,
    this.readOnly = false,
    this.enableSuggestions = false,
    this.autocorrect = false,
    this.obscureText = false,
    this.inputMask,
    this.inputFilter,
    this.inputMaskLazy = true,
    this.errorTextColor,
    this.errorText,
    this.labelText,
    this.helperText,
    this.labelMaxLines,
    this.placeholderText,
    this.focusNode,
    this.keyboardType,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.textInputAction,
    this.trailingIcon,
    this.onTrailingTap,
    this.suffixIcon,
    this.suffixIconColor,
    this.onSuffixTap,
    this.secondaryText,
    this.alwaysShowTrailing = true,
    this.showRemainingPlaceholder = false,
    this.enableTextAreaClearAction = true,
    this.trailingFormatters = const [],
    this.onTap,
    this.isFocusable = true,
    this.trailingConstraints = const BoxConstraints(minWidth: 44),
    this.capitalization = TextCapitalization.none,
    this.inputTextStyle,
    this.fillColor,
    this.placeholderStyle,
    this.alwaysShowBorder = false,
    super.key,
  }) : assert(!(!isFocusable && focusNode != null), 'focusNode must be null if focusable = false');

  final UiTextFieldController controller;
  final bool? enabled;
  final bool isFocusable;
  final bool autofocus;
  final bool readOnly;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool obscureText;
  final String? inputMask;
  final Map<String, RegExp>? inputFilter;
  final bool inputMaskLazy;
  final Color? errorTextColor;

  /// Принудительная ошибка (например, «Заполните поле» после нажатия на кнопку отправки).
  /// Если задана, показывается вместо ошибок валидаторов.
  final String? errorText;

  /// Подпись над полем.
  final String? labelText;

  /// Подсказка под полем.
  final String? helperText;
  final int? labelMaxLines;
  final String? placeholderText;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final int? maxLength;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final int maxLines;
  final int? minLines;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onEditingComplete;
  final void Function()? onTap;
  final TextInputAction? textInputAction;
  final Widget? trailingIcon;
  final VoidCallback? onTrailingTap;
  final IconData? suffixIcon;
  final Color? suffixIconColor;
  final VoidCallback? onSuffixTap;
  final String? secondaryText;
  final bool alwaysShowTrailing;
  final bool showRemainingPlaceholder;
  final bool enableTextAreaClearAction;
  final List<TextInputFormatter> trailingFormatters;
  final TextCapitalization capitalization;
  final BoxConstraints? trailingConstraints;
  final TextStyle? inputTextStyle;
  final Color? fillColor;
  final TextStyle? placeholderStyle;
  final bool alwaysShowBorder;

  @override
  State<UiTextField> createState() => _UiTextFieldState();
}

class _UiTextFieldState extends State<UiTextField> {
  FocusNode? _focusNode;
  late UiTextFieldController _controller = widget.controller;
  VoidCallback? _controllerListener;

  bool get _hasFocus => _focusNode?.hasFocus ?? false;

  bool get _isEnabled => widget.enabled ?? true;

  // Показываем ошибку только если поле было «тронуто».
  bool get _hasError =>
      widget.errorText != null ||
      (_controller.touched && _controller.validators.hasValidationMessage(_controller.text));

  BorderSide _borderSide(UiPalette palette) {
    if (_hasError) {
      return BorderSide(color: palette.danger, width: 2);
    }

    if (_hasFocus || widget.alwaysShowBorder) {
      return BorderSide(color: palette.accent, width: 2);
    }

    if (!_isEnabled) {
      return BorderSide(color: palette.line);
    }

    return BorderSide(color: palette.controlLine);
  }

  @override
  void initState() {
    super.initState();

    _focusNode = widget.isFocusable ? (widget.focusNode ?? FocusNode()) : null;
    _controller = widget.controller;

    /// Listener нужен для rebuild TextField после изменения значения в контроллере
    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener!);

    _focusNode?.addListener(() {
      // Помечаем поле как "тронутое" при потере фокуса
      if (!_hasFocus && _controller.text.isNotEmpty) {
        _controller.markAsTouched();
      }
      setState(() {}); // Rebuild when focus changes, to update the border
    });
  }

  @override
  void didUpdateWidget(UiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Контроллером владеет вызывающая сторона, поэтому мы его НЕ диспоузим.
    // Здесь нужно только перекинуть listener при замене контроллера.
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_controllerListener!);
      _controller = widget.controller;
      _controller.addListener(_controllerListener!);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode?.dispose();
    }

    _controller.removeListener(_controllerListener!);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.uiPalette;
    final fonts = context.uiFonts;
    final enabled = _isEnabled;
    final borderSide = _borderSide(palette);
    final border = OutlineInputBorder(borderRadius: UiRadius.mdAll, borderSide: borderSide);

    // Ошибку под полем показываем только когда нет ограничения длины (счётчик занимает место).
    final errorText = _hasError && widget.maxLength == null ? _getErrorText() : null;
    final showFocusRing = _hasFocus && !_hasError;

    return UiFormField(
      label: widget.labelText,
      helperText: widget.helperText,
      errorText: errorText,
      child: AnimatedContainer(
        duration: UiMotion.base,
        curve: UiMotion.curve,
        decoration: BoxDecoration(
          borderRadius: UiRadius.mdAll,
          boxShadow: [
            if (showFocusRing) BoxShadow(color: palette.accentTint, spreadRadius: UiSpacing.x1),
          ],
        ),
        child: TextField(
          textCapitalization: widget.capitalization,
          onTap: widget.onTap,
          onChanged: (value) {
            // Помечаем поле как "тронутое" при начале ввода
            if (!_controller.touched) {
              _controller.markAsTouched();
            }
            widget.onChanged?.call(value);
          },
          onSubmitted: widget.onSubmitted,
          onEditingComplete: widget.onEditingComplete,
          textInputAction: widget.textInputAction,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          obscureText: widget.obscureText,
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          maxLengthEnforcement: widget.maxLengthEnforcement,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          cursorColor: palette.accent,
          style:
              widget.inputTextStyle ??
              fonts.body.copyWith(color: enabled ? palette.ink : palette.ink3),
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.placeholderText,
            hintMaxLines: widget.labelMaxLines,
            hintStyle:
                widget.placeholderStyle ??
                fonts.body.copyWith(color: palette.ink3, overflow: TextOverflow.ellipsis),
            prefixIcon: widget.trailingIcon == null
                ? null
                : GestureDetector(onTap: widget.onTrailingTap, child: widget.trailingIcon),
            prefixIconConstraints: widget.trailingIcon == null ? null : widget.trailingConstraints,
            suffixIcon: widget.secondaryText == null && widget.suffixIcon == null
                ? null
                : _SuffixWidget(
                    secondaryText: widget.secondaryText,
                    suffixIcon: widget.suffixIcon,
                    hasFocus: _hasFocus,
                    suffixIconColor: widget.suffixIconColor,
                    onSuffixTap: widget.onSuffixTap,
                    alwaysShowTrailing: widget.alwaysShowTrailing,
                  ),
            filled: true,
            fillColor: widget.fillColor ?? (enabled ? palette.surface : palette.sunken),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: UiSpacing.x4,
              vertical: UiSpacing.x4,
            ),
            disabledBorder: border,
            enabledBorder: border,
            focusedBorder: border,
          ),
          inputFormatters: [
            if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
            MaskTextInputFormatter(
              initialText: _controller.text,
              mask: widget.inputMask,
              filter: widget.inputFilter,
              type: widget.inputMaskLazy
                  ? MaskAutoCompletionType.lazy
                  : MaskAutoCompletionType.eager,
            ),
            ...widget.trailingFormatters,
          ],
        ),
      ),
    );
  }

  String _getErrorText() {
    if (widget.errorText != null) {
      return widget.errorText!;
    }

    final errorText = _controller.validators.getFirstValidationMessage(_controller.text) ?? '';

    return errorText;
  }
}

class _SuffixWidget extends StatelessWidget {
  const _SuffixWidget({
    required this.secondaryText,
    required this.suffixIcon,
    required this.hasFocus,
    required this.suffixIconColor,
    required this.onSuffixTap,
    required this.alwaysShowTrailing,
  });

  final String? secondaryText;
  final IconData? suffixIcon;
  final bool hasFocus;
  final Color? suffixIconColor;
  final VoidCallback? onSuffixTap;
  final bool alwaysShowTrailing;

  @override
  Widget build(BuildContext context) {
    if (secondaryText == null && suffixIcon == null) {
      return const SizedBox.shrink();
    }

    if (alwaysShowTrailing || hasFocus) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (secondaryText != null)
            Flexible(
              child: Text(
                secondaryText!,
                overflow: TextOverflow.ellipsis,
                style: context.uiFonts.bodyBold.copyWith(color: context.uiPalette.ink),
              ),
            ),
          if (suffixIcon == null) const SizedBox(width: 12),
          if (suffixIcon != null)
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: onSuffixTap,
              icon: Icon(suffixIcon, size: 24, color: suffixIconColor ?? context.uiPalette.ink2),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
