import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_flyout/ui_flyout.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

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
    textStyle: context.uiFonts.text20Semibold.copyWith(color: context.uiColors.black100),
    selectedTextStyle: context.uiFonts.text20Semibold.copyWith(color: context.uiColors.black100),
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
        final formatted = '${widget.initialHour?.toString().padLeft(2, '0')}:${widget.initialMinute?.toString().padLeft(2, '0')}';
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
          color: context.uiColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: context.uiColors.black100.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                  'Очистить',
                  style: context.uiFonts.text16Semibold.copyWith(color: context.uiColors.brown),
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
