import 'package:flutter/widgets.dart';

/// Вызывает [onShown] один раз, когда виджет впервые появился на экране.
///
/// Нужен для событий «показано»: пустое состояние, ошибка. Повторные перестройки
/// событие не дублируют; новое появление виджета (новый State) считается новым показом.
class AnalyticsImpression extends StatefulWidget {
  /// Создаёт обёртку.
  const AnalyticsImpression({required this.onShown, required this.child, super.key});

  /// Действие при первом показе.
  final VoidCallback onShown;

  /// Содержимое.
  final Widget child;

  @override
  State<AnalyticsImpression> createState() => _AnalyticsImpressionState();
}

class _AnalyticsImpressionState extends State<AnalyticsImpression> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onShown();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
