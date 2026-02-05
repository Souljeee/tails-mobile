import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/components/ui_radio/ui_radio.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';
import 'package:tails_mobile/src/feature/pets/core/enums/pet_sex_enum.dart';

class CastrationSection extends StatefulWidget {
  final PetSexEnum gender;
  final void Function(bool) onSelected;

  const CastrationSection({
    required this.gender,
    required this.onSelected,
    super.key,
  });

  @override
  State<CastrationSection> createState() => _CastrationSectionState();
}

class _CastrationSectionState extends State<CastrationSection> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
        });
        widget.onSelected(_isSelected);
      },
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
              UiRadio(isSelected: _isSelected),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.gender == PetSexEnum.male ? 'Кастрирован' : 'Стерилизована',
                  style: context.uiFonts.header20Medium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
