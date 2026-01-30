import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/theme/theme_x.dart';

class UiSwitcherOption<T> extends Equatable {
  final T value;
  final String label;
  final IconData icon;

  const UiSwitcherOption({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  List<Object?> get props => [
        value,
        label,
        icon,
      ];
}

class UiSwitcher<T> extends StatefulWidget {
  final List<UiSwitcherOption<T>> options;
  final void Function(T type) onTypeChanged;

  const UiSwitcher({
    required this.options,
    required this.onTypeChanged,
    super.key,
  }) : assert(options.length == 2, 'Options must be exactly 2');

  @override
  State<UiSwitcher<T>> createState() => _UiSwitcherState<T>();
}

class _UiSwitcherState<T> extends State<UiSwitcher<T>> {
  late T _selectedType = widget.options.first.value;

  void _onTypeSelected(T type) {
    if (_selectedType != type) {
      setState(() {
        _selectedType = type;
      });

      widget.onTypeChanged(type);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE8E1),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment:
                  _selectedType == widget.options.first.value ? Alignment.centerLeft : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.uiColors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: context.uiColors.black100.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (final option in widget.options)
                  Expanded(
                    child: _Option<T>(
                      option: option,
                      isSelected: _selectedType == option.value,
                      onTap: _onTypeSelected,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Option<T> extends StatelessWidget {
  final UiSwitcherOption<T> option;
  final bool isSelected;
  final void Function(T type) onTap;

  const _Option({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(option.value),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        color: Colors.transparent,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  option.icon,
                  key: ValueKey('${option.value}-$isSelected'),
                  size: 24,
                  color: isSelected ? context.uiColors.brown : context.uiColors.orangePrimary,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? context.uiColors.brown : context.uiColors.orangePrimary,
                ),
                child: Text(option.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
