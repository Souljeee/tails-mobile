import 'package:flutter/material.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_button/ui_button.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_spacing.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';

/// Содержимое sheet выбора веса: килограммы и граммы с шагом 100 г.
/// Закрывается, возвращая `[кг, г]`.
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
    data: const [NumberPickerColumn(end: 100), NumberPickerColumn(end: 900, jump: 100)],
  );

  late final List<int> _initialSelecteds;

  late final Picker _picker = Picker(
    adapter: _adapter,
    hideHeader: true,
    itemExtent: 44,
    selecteds: _initialSelecteds,
    backgroundColor: Colors.transparent,
    textStyle: context.uiFonts.monoDigits.copyWith(color: context.uiPalette.ink, fontSize: 20),
    selectedTextStyle: context.uiFonts.monoDigits.copyWith(
      color: context.uiPalette.ink,
      fontSize: 20,
    ),
  );

  @override
  void initState() {
    super.initState();
    final initialKg = widget.initialKilograms.clamp(0, 100);
    final initialGrams = (widget.initialGrams.clamp(0, 900) ~/ 100) * 100;
    _initialSelecteds = [initialKg, initialGrams ~/ 100];
  }

  void _onConfirm() {
    final values = _picker.getSelectedValues();

    final kilograms = (values[0] as num).toInt().clamp(0, 100);
    final grams = (values[1] as num).toInt().clamp(0, 900);
    final normalizedGrams = (grams ~/ 100) * 100;

    Navigator.of(context).pop<List<int>>([kilograms, normalizedGrams]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unitStyle = context.uiFonts.footnote.copyWith(color: context.uiPalette.ink3);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiSheetHeader(title: l10n.petFormWeight, cancelLabel: l10n.cancel),
        const SizedBox(height: UiSpacing.x2),
        Row(
          children: [
            Expanded(
              child: Text(l10n.weightKgUnit, textAlign: TextAlign.center, style: unitStyle),
            ),
            Expanded(
              child: Text(l10n.weightGramsUnit, textAlign: TextAlign.center, style: unitStyle),
            ),
          ],
        ),
        const SizedBox(height: UiSpacing.x2),
        SizedBox(height: 216, child: _picker.makePicker()),
        const SizedBox(height: UiSpacing.x4),
        UiButton.main(label: l10n.done, onPressed: _onConfirm),
      ],
    );
  }
}
