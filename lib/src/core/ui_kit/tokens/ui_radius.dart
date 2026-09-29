import 'package:flutter/painting.dart';

/// Радиусы скругления Design 2.0.
abstract final class UiRadius {
  /// Чипы, мелкие элементы.
  static const double sm = 12;

  /// Поля ввода, кнопки, карточки событий.
  static const double md = 16;

  /// Крупные карточки и календарь.
  static const double lg = 24;

  /// Фото-шапки, листы.
  static const double xl = 32;

  /// Полное скругление (пилюли, круги).
  static const double full = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius fullAll = BorderRadius.all(Radius.circular(full));
}
