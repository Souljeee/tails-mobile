import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/pets/add_pet/persentation/widgets/weight_picker_bottom_sheet.dart';

class WeightPicker extends StatefulWidget {
  final void Function(double) onWeightSelected;
  final double? initialWeight;

  const WeightPicker({
    required this.onWeightSelected,
    this.initialWeight,
    super.key,
  });

  @override
  State<WeightPicker> createState() => _WeightPickerState();
}

class _WeightPickerState extends State<WeightPicker> {
  late double? _weight = widget.initialWeight;

  String _formatWeight(double weightKg) {
    final kg = weightKg.floor().clamp(0, 100);
    final grams = ((weightKg - kg) * 1000).round().clamp(0, 900);
    final normalizedGrams = (grams ~/ 100) * 100;

    if (normalizedGrams == 0) return '$kg кг';

    // Так как граммы выбираются шагом 100, отображаем как одну десятичную: 2,3 кг
    final tenths = (normalizedGrams ~/ 100).clamp(0, 9);
    return '$kg,$tenths кг';
  }

  Future<void> _openWeightPicker() async {
    final current = _weight ?? 0.0;
    final kg = current.floor().clamp(0, 100);
    final grams = (((current - kg) * 1000).round() ~/ 100) * 100;

    final selected = await showModalBottomSheet<List<int>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => WeightPickerBottomSheet(
        initialKilograms: kg,
        initialGrams: grams,
      ),
    );

    if (selected == null) return;

    final selectedKg = selected[0].clamp(0, 100);
    final selectedGrams = (selected[1].clamp(0, 900) ~/ 100) * 100;
    final weight = selectedKg + (selectedGrams / 1000.0);

    _onWeightSelected(weight);
  }

  void _onWeightSelected(double weight) {
    setState(() {
      _weight = weight;
    });

    widget.onWeightSelected(weight);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openWeightPicker,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.uiColors.black5,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Вес',
                      style: context.uiFonts.header20Medium,
                    ),
                    if(_weight != null)...[
                      const SizedBox(height: 8),
                      Text(
                        _formatWeight(_weight!),
                        style: context.uiFonts.text16Semibold.copyWith(color: context.uiColors.brown),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.uiColors.brown,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
