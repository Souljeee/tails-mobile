import 'package:flutter/material.dart';

/// Семантическая палитра Design 2.0.
///
/// Написана вручную, без кодогенерации. Доступна через `context.uiPalette`.
@immutable
class UiPalette extends ThemeExtension<UiPalette> {
  const UiPalette({
    required this.accent,
    required this.accentPressed,
    required this.accentTint,
    required this.canvas,
    required this.surface,
    required this.sunken,
    required this.line,
    required this.controlLine,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.pine,
    required this.pineTint,
    required this.amber,
    required this.amberTint,
    required this.danger,
    required this.dangerTint,
    required this.petColors,
  });

  /// Светлая палитра из макетов.
  const UiPalette.light()
    : accent = const Color(0xFFA94D2A),
      accentPressed = const Color(0xFF8F3F21),
      accentTint = const Color(0xFFF6E3D8),
      canvas = const Color(0xFFF6F2EC),
      surface = const Color(0xFFFFFFFF),
      sunken = const Color(0xFFEFE9E1),
      line = const Color(0xFFE6DFD5),
      controlLine = const Color(0xFF948A7E),
      ink = const Color(0xFF1D1B18),
      ink2 = const Color(0xFF5F5850),
      ink3 = const Color(0xFF7A7167),
      pine = const Color(0xFF2F5F52),
      pineTint = const Color(0xFFE3EDE8),
      amber = const Color(0xFF9A6416),
      amberTint = const Color(0xFFF7ECD9),
      danger = const Color(0xFFB3261E),
      dangerTint = const Color(0xFFF8E4E2),
      petColors = _petColors;

  /// Тёмная палитра «Сланец» (токены дизайн-системы, тема `dark`).
  const UiPalette.dark()
    : accent = const Color(0xFFB8562F),
      accentPressed = const Color(0xFF9F4A28),
      accentTint = const Color(0xFF352722),
      canvas = const Color(0xFF111518),
      surface = const Color(0xFF1A1F23),
      sunken = const Color(0xFF242A2F),
      line = const Color(0xFF30373D),
      controlLine = const Color(0xFF737D85),
      ink = const Color(0xFFF0F2F3),
      ink2 = const Color(0xFFADB5BB),
      ink3 = const Color(0xFF87919A),
      pine = const Color(0xFF7FC9B0),
      pineTint = const Color(0xFF18302B),
      amber = const Color(0xFFE6B86E),
      amberTint = const Color(0xFF332C1D),
      danger = const Color(0xFFF48E86),
      dangerTint = const Color(0xFF3A2025),
      petColors = _petColors;

  static const List<Color> _petColors = [
    Color(0xFF6F8F6B),
    Color(0xFF5B7FA6),
    Color(0xFF8E5E84),
    Color(0xFFA87A32),
    Color(0xFFB05A64),
  ];

  /// Основной акцент: кнопки, активные элементы, ссылки.
  final Color accent;
  final Color accentPressed;
  final Color accentTint;

  /// Фон экрана.
  final Color canvas;

  /// Фон карточек и полей.
  final Color surface;

  /// Утопленные области (сегмент-контролы, заглушки фото).
  final Color sunken;

  /// Разделители и границы карточек.
  final Color line;

  /// Границы интерактивных контролов (контраст 3:1).
  final Color controlLine;

  /// Основной текст.
  final Color ink;
  final Color ink2;
  final Color ink3;

  /// Успех, выполнено.
  final Color pine;
  final Color pineTint;

  /// Предупреждение.
  final Color amber;
  final Color amberTint;

  /// Ошибка, удаление.
  final Color danger;
  final Color dangerTint;

  /// Цвета питомцев для меток, точек календаря и полос событий.
  final List<Color> petColors;

  /// Цвет питомца по его порядковому номеру; палитра повторяется по кругу.
  Color petColor(int index) => petColors[index % petColors.length];

  @override
  UiPalette copyWith({
    Color? accent,
    Color? accentPressed,
    Color? accentTint,
    Color? canvas,
    Color? surface,
    Color? sunken,
    Color? line,
    Color? controlLine,
    Color? ink,
    Color? ink2,
    Color? ink3,
    Color? pine,
    Color? pineTint,
    Color? amber,
    Color? amberTint,
    Color? danger,
    Color? dangerTint,
    List<Color>? petColors,
  }) => UiPalette(
    accent: accent ?? this.accent,
    accentPressed: accentPressed ?? this.accentPressed,
    accentTint: accentTint ?? this.accentTint,
    canvas: canvas ?? this.canvas,
    surface: surface ?? this.surface,
    sunken: sunken ?? this.sunken,
    line: line ?? this.line,
    controlLine: controlLine ?? this.controlLine,
    ink: ink ?? this.ink,
    ink2: ink2 ?? this.ink2,
    ink3: ink3 ?? this.ink3,
    pine: pine ?? this.pine,
    pineTint: pineTint ?? this.pineTint,
    amber: amber ?? this.amber,
    amberTint: amberTint ?? this.amberTint,
    danger: danger ?? this.danger,
    dangerTint: dangerTint ?? this.dangerTint,
    petColors: petColors ?? this.petColors,
  );

  @override
  UiPalette lerp(ThemeExtension<UiPalette>? other, double t) {
    if (other is! UiPalette) {
      return this;
    }

    return UiPalette(
      accent: Color.lerp(accent, other.accent, t)!,
      accentPressed: Color.lerp(accentPressed, other.accentPressed, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      sunken: Color.lerp(sunken, other.sunken, t)!,
      line: Color.lerp(line, other.line, t)!,
      controlLine: Color.lerp(controlLine, other.controlLine, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      ink2: Color.lerp(ink2, other.ink2, t)!,
      ink3: Color.lerp(ink3, other.ink3, t)!,
      pine: Color.lerp(pine, other.pine, t)!,
      pineTint: Color.lerp(pineTint, other.pineTint, t)!,
      amber: Color.lerp(amber, other.amber, t)!,
      amberTint: Color.lerp(amberTint, other.amberTint, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerTint: Color.lerp(dangerTint, other.dangerTint, t)!,
      petColors: [
        for (var i = 0; i < petColors.length; i++)
          Color.lerp(petColors[i], other.petColors[i % other.petColors.length], t)!,
      ],
    );
  }
}
