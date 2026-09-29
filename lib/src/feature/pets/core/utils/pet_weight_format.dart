/// Форматирует вес в килограммах для отображения: `14,9`, `15`, `4,25`.
///
/// Показывает до двух знаков после запятой без незначащих нулей.
/// Единицу измерения («кг») добавляет вызывающий код.
String formatPetWeight(double weightKg) {
  final fixed = weightKg.toStringAsFixed(2);
  final trimmed = fixed.replaceFirst(RegExp(r'\.?0+$'), '');

  return trimmed.replaceFirst('.', ',');
}
