import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_bottom_sheet/ui_bottom_sheet.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_textfield/ui_textfield_controller.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/weight_picker_bottom_sheet.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_weight_format.dart';

/// Поле веса: показывает число с суффиксом «кг», по нажатию открывает пикер.
class WeightPicker extends StatefulWidget {
  final void Function(double) onWeightSelected;
  final double? initialWeight;

  const WeightPicker({required this.onWeightSelected, this.initialWeight, super.key});

  @override
  State<WeightPicker> createState() => _WeightPickerState();
}

class _WeightPickerState extends State<WeightPicker> {
  late double? _weight = widget.initialWeight;
  late final UiTextFieldController _controller = UiTextFieldController(
    text: _weight == null ? '' : formatPetWeight(_weight!),
  );

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Future<void> _openWeightPicker() async {
    final current = _weight ?? 0.0;
    final kg = current.floor().clamp(0, 100);
    final grams = (((current - kg) * 1000).round() ~/ 100) * 100;

    final selected = await showUiBottomSheet<List<int>>(
      context: context,
      builder: (_) => WeightPickerBottomSheet(initialKilograms: kg, initialGrams: grams),
    );

    if (selected == null) return;

    final selectedKg = selected[0].clamp(0, 100);
    final selectedGrams = (selected[1].clamp(0, 900) ~/ 100) * 100;
    final weight = selectedKg + (selectedGrams / 1000.0);

    setState(() {
      _weight = weight;
      _controller.text = formatPetWeight(weight);
    });

    widget.onWeightSelected(weight);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openWeightPicker,
      child: AbsorbPointer(
        child: UiTextField(
          controller: _controller,
          labelText: l10n.petFormWeight,
          placeholderText: l10n.petFormWeightPlaceholder,
          secondaryText: l10n.weightKgUnit,
        ),
      ),
    );
  }
}
