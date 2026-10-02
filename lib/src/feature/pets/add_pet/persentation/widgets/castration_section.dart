import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_switch_row/ui_switch_row.dart';
import 'package:tails_mobile/src/core/utils/extensions/l10n_extension.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';

class CastrationSection extends StatefulWidget {
  final PetSexEnum gender;
  final ValueChanged<bool> onSelected;
  final bool initialSelection;

  const CastrationSection({
    required this.gender,
    required this.onSelected,
    this.initialSelection = false,
    super.key,
  });

  @override
  State<CastrationSection> createState() => _CastrationSectionState();
}

class _CastrationSectionState extends State<CastrationSection> {
  late bool _isSelected = widget.initialSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return UiSwitchRow(
      title: widget.gender == PetSexEnum.male ? l10n.petCastratedMale : l10n.petCastratedFemale,
      subtitle: l10n.petCastratedHint,
      value: _isSelected,
      onChanged: (value) {
        setState(() {
          _isSelected = value;
        });
        widget.onSelected(value);
      },
    );
  }
}
