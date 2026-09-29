import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_radius.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_shadows.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

class TimePickerCarouselPopup extends StatefulWidget {
  const TimePickerCarouselPopup({
    required this.onTimeSelected,
    required this.onClear,
    this.initialHour,
    this.initialMinute,
    super.key,
  });

  final void Function(String time) onTimeSelected;
  final void Function() onClear;
  final int? initialHour;
  final int? initialMinute;

  @override
  State<TimePickerCarouselPopup> createState() => _TimePickerCarouselPopupState();
}

class _TimePickerCarouselPopupState extends State<TimePickerCarouselPopup> {
  Timer? _debounceTimer;

  late final List<int> _selecteds = [
    (widget.initialHour ?? 0).clamp(0, 23),
    (widget.initialMinute ?? 0).clamp(0, 59),
  ];

  late final Picker _picker = Picker(
    adapter: NumberPickerAdapter(
      data: [
        NumberPickerColumn(end: 23, onFormatValue: (value) => value.toString().padLeft(2, '0')),
        NumberPickerColumn(end: 59, onFormatValue: (value) => value.toString().padLeft(2, '0')),
      ],
    ),
    hideHeader: true,
    itemExtent: 44,
    columnPadding: EdgeInsets.zero,
    selecteds: _selecteds,
    textStyle: context.uiFonts.monoDigits.copyWith(color: context.uiPalette.ink, fontSize: 20),
    selectedTextStyle: context.uiFonts.monoDigits.copyWith(
      color: context.uiPalette.ink,
      fontSize: 20,
    ),
    onSelect: _onSelect,
  );

  void _onSelect(Picker picker, int index, List<int> selected) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final values = picker.getSelectedValues();
      final hour = (values[0] as num).toInt().clamp(0, 23);
      final minute = (values[1] as num).toInt().clamp(0, 59);
      final formatted = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      widget.onTimeSelected(formatted);
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.initialHour != null && widget.initialMinute != null) {
        final formatted =
            '${widget.initialHour?.toString().padLeft(2, '0')}:${widget.initialMinute?.toString().padLeft(2, '0')}';
        widget.onTimeSelected(formatted);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.uiPalette.surface,
          borderRadius: UiRadius.lgAll,
          border: Border.all(color: context.uiPalette.line),
          boxShadow: UiShadows.e2,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  widget.onClear();
                },
                child: Text(
                  context.l10n.timePickerClear,
                  style: context.uiFonts.callout.copyWith(
                    color: context.uiPalette.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _picker.makePicker(),
            ],
          ),
        ),
      ),
    );
  }
}
