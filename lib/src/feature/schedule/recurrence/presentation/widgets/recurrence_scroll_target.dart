import 'package:flutter/material.dart';
import 'package:tails_mobile/src/core/ui_kit/tokens/ui_motion.dart';

/// Когда [active] становится `true` (открыли барабан), прокручивает список так, чтобы
/// [child] оказался над панелью.
class RecurrenceScrollTarget extends StatefulWidget {
  const RecurrenceScrollTarget({required this.active, required this.child, super.key});

  final bool active;
  final Widget child;

  @override
  State<RecurrenceScrollTarget> createState() => _RecurrenceScrollTargetState();
}

class _RecurrenceScrollTargetState extends State<RecurrenceScrollTarget> {
  @override
  void didUpdateWidget(RecurrenceScrollTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Scrollable.ensureVisible(
            context,
            duration: UiMotion.base,
            curve: UiMotion.curve,
            alignment: 0.5,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
