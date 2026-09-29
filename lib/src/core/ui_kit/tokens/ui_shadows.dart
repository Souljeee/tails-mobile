import 'package:flutter/painting.dart';

/// Тени Design 2.0.
///
/// Параметры подобраны по макетам приблизительно; сверить с дизайнером.
abstract final class UiShadows {
  /// Карточки и элементы списков.
  static const List<BoxShadow> e1 = [
    BoxShadow(color: Color(0x0F1D1B18), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Плавающие элементы: навигация, кнопка «+».
  static const List<BoxShadow> e2 = [
    BoxShadow(color: Color(0x241D1B18), blurRadius: 24, offset: Offset(0, 8)),
  ];
}
