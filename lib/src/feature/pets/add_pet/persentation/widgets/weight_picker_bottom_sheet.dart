import 'package:flutter/material.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class WeightPickerBottomSheet extends StatefulWidget {
  const WeightPickerBottomSheet({
    required this.initialKilograms,
    required this.initialGrams,
    super.key,
  });

  final int initialKilograms;
  final int initialGrams;

  @override
  State<WeightPickerBottomSheet> createState() => _WeightPickerBottomSheetState();
}

class _WeightPickerBottomSheetState extends State<WeightPickerBottomSheet> {
  late final NumberPickerAdapter _adapter = NumberPickerAdapter(
    data: const [
      NumberPickerColumn(end: 100),
      NumberPickerColumn(end: 900, jump: 100),
    ],
  );

  late final List<int> _initialSelecteds;

  late final Picker _picker = Picker(
    adapter: _adapter,
    hideHeader: true,
    itemExtent: 44,
    selecteds: _initialSelecteds,
    textStyle: context.uiFonts.text20Semibold.copyWith(color: context.uiColors.black100),
    selectedTextStyle: context.uiFonts.text20Semibold.copyWith(color: context.uiColors.black100),
  );

  @override
  void initState() {
    super.initState();
    final initialKg = widget.initialKilograms.clamp(0, 100);
    final initialGrams = (widget.initialGrams.clamp(0, 900) ~/ 100) * 100;
    _initialSelecteds = [initialKg, initialGrams ~/ 100];
  }

  void _onCancel() => Navigator.of(context).pop();

  void _onConfirm() {
    final values = _picker.getSelectedValues();

    final kilograms = (values[0] as num).toInt().clamp(0, 100);
    final grams = (values[1] as num).toInt().clamp(0, 900);
    final normalizedGrams = (grams ~/ 100) * 100;

    Navigator.of(context).pop<List<int>>([kilograms, normalizedGrams]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: context.uiColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 12, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _onCancel,
                    child: Text(
                      'Отмена',
                      style: context.uiFonts.text16Regular.copyWith(color: context.uiColors.brown),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Вес',
                      textAlign: TextAlign.center,
                      style: context.uiFonts.text16Semibold,
                    ),
                  ),
                  TextButton(
                    onPressed: _onConfirm,
                    child: Text(
                      'Готово',
                      style: context.uiFonts.text16Regular.copyWith(color: context.uiColors.brown),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'кг',
                      textAlign: TextAlign.center,
                      style: context.uiFonts.text12Medium.copyWith(color: context.uiColors.black40),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'г',
                      textAlign: TextAlign.center,
                      style: context.uiFonts.text12Medium.copyWith(color: context.uiColors.black40),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 216,
              child: _picker.makePicker(),
            ),
          ],
        ),
      ),
    );
  }
}
