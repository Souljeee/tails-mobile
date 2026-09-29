import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tails_mobile/src/core/ui_kit/colors/ui_palette.dart';

void main() {
  group('UiPalette.petColor', () {
    const palette = UiPalette.light();

    test('первые два питомца получают зелёный и синий цвета из макетов', () {
      expect(palette.petColor(0), const Color(0xFF6F8F6B));
      expect(palette.petColor(1), const Color(0xFF5B7FA6));
    });

    test('палитра повторяется по кругу', () {
      expect(palette.petColor(palette.petColors.length), palette.petColor(0));
    });
  });

  group('UiPalette.lerp', () {
    test('на границах возвращает исходные палитры', () {
      const light = UiPalette.light();
      const dark = UiPalette.dark();

      expect(light.lerp(dark, 0).accent, light.accent);
      expect(light.lerp(dark, 1).accent, dark.accent);
    });
  });
}
