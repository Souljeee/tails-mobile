import 'package:flutter/animation.dart';

/// Длительности и кривые анимаций Design 2.0.
abstract final class UiMotion {
  /// Стандартные переходы состояний.
  static const Duration base = Duration(milliseconds: 200);

  /// Крупные переходы (растягивание панели, смена экранов).
  static const Duration large = Duration(milliseconds: 300);

  static const Curve curve = Curves.easeOut;
}
