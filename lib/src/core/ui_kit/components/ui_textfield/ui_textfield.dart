import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tails_mobile/src/core/ui_kit/colors/ui_color_scheme.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_svg_image/ui_svg_image.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_validators.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

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
    this.labelText,
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
    this.suffixIconPath,
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
  }) : assert(
          !(!isFocusable && focusNode != null),
          'focusNode must be null if focusable = false',
        );

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
  final String? labelText;
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
  final String? suffixIconPath;
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
  bool _pressed = false;
  FocusNode? _focusNode;
  late UiTextFieldController _controller = widget.controller;
  VoidCallback? _controllerListener;

  bool get _hasFocus => _focusNode?.hasFocus ?? false;

  bool get _scaleLabel => _hasFocus || (_controller.text.isNotEmpty);

  EdgeInsets get _labelPadding => EdgeInsets.only(top: _scaleLabel ? 11 : 23, left: 16);

  TextStyle get _labelStyle {
    final enabled = widget.enabled ?? true;
    final baseStyle = _scaleLabel ? context.uiFonts.text12Regular : context.uiFonts.text16Regular;
    final color =
        enabled ? context.uiColors.black40 : context.uiColors.black40.withValues(alpha: 0.5);

    return baseStyle.copyWith(color: color);
  }

  Set<_InputState> get _currentStates {
    final states = <_InputState>{};

    if (_hasFocus) {
      states.add(_InputState.focused);
    }

    if (!(widget.enabled ?? true)) {
      states.add(_InputState.disabled);
    }

    // Показываем ошибку только если поле было "тронуто"
    if (_controller.touched && widget.controller.validators.hasValidationMessage(_controller.text)) {
      states.add(_InputState.error);
    }

    if (widget.enabled ?? true) {
      states.add(_pressed ? _InputState.pressed : _InputState.static);
    }

    return states;
  }

  BorderSide get _borderSide {
    if (widget.alwaysShowBorder) {
      if (_currentStates.contains(_InputState.error)) {
        return BorderSide(color: context.uiColors.red);
      } else {
        return BorderSide(color: context.uiColors.brown);
      }
    }

    if (_currentStates.contains(_InputState.error)) {
      return BorderSide(color: context.uiColors.red);
    } else if (_currentStates.contains(_InputState.focused)) {
      return BorderSide(color: context.uiColors.brown);
    }

    return BorderSide.none;
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
      setState(() {}); // Rebuild when focus changes, to reset position of label
    });
  }

  @override
  void didUpdateWidget(UiTextField oldWidget) {
    if (oldWidget.placeholderText != widget.placeholderText ||
        oldWidget.focusNode != widget.focusNode ||
        oldWidget.controller != widget.controller) {
      _controller.removeListener(_controllerListener!);

      _controller.dispose();

      _controller = widget.controller;

      _controller.addListener(_controllerListener!);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode?.dispose();
    }

    _controller.removeListener(_controllerListener!);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.uiColorScheme;
    final themeTypography = context.uiFonts;
    final enabled = widget.enabled ?? true;

    // Показываем ошибки только если поле было "тронуто"
    final bool hasValidationErrors = 
        _controller.touched && _controller.validators.hasValidationMessage(_controller.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            Listener(
              onPointerUp: (_) => setState(() => _pressed = false),
              onPointerDown: (_) => setState(() => _pressed = true),
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
                cursorColor: colors.black100,
                style: widget.inputTextStyle ??
                    themeTypography.text16Regular.copyWith(
                      color: enabled ? colors.black100 : colors.black100.withValues(alpha: 0.5),
                    ),
                textAlignVertical: TextAlignVertical.bottom,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.labelText == null || _hasFocus ? widget.placeholderText : null,
                  hintMaxLines: widget.labelMaxLines,
                  hintStyle: widget.placeholderStyle ??
                      themeTypography.text16Regular.copyWith(
                        color: colors.black50,
                        overflow: TextOverflow.ellipsis,
                      ),
                  prefixIcon: GestureDetector(
                    onTap: widget.onTrailingTap,
                    child: widget.trailingIcon,
                  ),
                  // prefix: GestureDetector(
                  //   onTap: widget.onTrailingTap,
                  //   child: widget.trailingIcon,
                  // ),
                  //prefixText: '+7',
                  //prefixIconConstraints: const BoxConstraints(minWidth: 44, maxWidth: 44, minHeight: 44, maxHeight: 44),
                  suffixIcon: _SuffixWidget(
                    secondaryText: widget.secondaryText,
                    suffixIconPath: widget.suffixIconPath,
                    hasFocus: _hasFocus,
                    suffixIconColor: widget.suffixIconColor,
                    onSuffixTap: widget.onSuffixTap,
                    alwaysShowTrailing: widget.alwaysShowTrailing,
                  ),
                  filled: true,
                  fillColor: widget.fillColor ??
                      (enabled ? colors.black5 : colors.black5.withValues(alpha: 0.5)),
                  contentPadding: widget.labelText != null
                      ? const EdgeInsets.fromLTRB(16, 31, 16, 11)
                      : const EdgeInsets.fromLTRB(16, 21, 16, 21),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(48),
                    borderSide: _borderSide,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(48),
                    borderSide: _borderSide,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(48),
                    borderSide: _borderSide,
                  ),
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
            if (widget.labelText != null)
              IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: _labelPadding,
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: _labelStyle,
                    child: Text(
                      widget.labelText ?? '',
                      maxLines: widget.labelMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (hasValidationErrors && widget.maxLength == null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _getErrorText(),
              style: themeTypography.text14Medium.copyWith(color: colors.red),
            ),
          ),
      ],
    );
  }

  String _getErrorText() {
    final errorText = _controller.validators.getFirstValidationMessage(_controller.text) ?? '';

    return errorText;
  }
}

class _SuffixWidget extends StatelessWidget {
  const _SuffixWidget({
    required this.secondaryText,
    required this.suffixIconPath,
    required this.hasFocus,
    required this.suffixIconColor,
    required this.onSuffixTap,
    required this.alwaysShowTrailing,
  });

  final String? secondaryText;
  final String? suffixIconPath;
  final bool hasFocus;
  final Color? suffixIconColor;
  final VoidCallback? onSuffixTap;
  final bool alwaysShowTrailing;

  @override
  Widget build(BuildContext context) {
    if (secondaryText == null && suffixIconPath == null) {
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
                style: context.uiFonts.text16Regular.copyWith(color: context.uiColors.black40),
              ),
            ),
          if (suffixIconPath == null) const SizedBox(width: 12),
          if (suffixIconPath != null)
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: onSuffixTap,
              icon: UiSvgImage(
                svgPath: suffixIconPath!,
                color: suffixIconColor ?? context.uiColors.black100,
              ),
            ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

enum _InputState { focused, disabled, pressed, error, static }
