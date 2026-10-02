/// Количество цветов в палитре питомцев (`UiPalette.petColors`).
const int petPaletteSize = 5;

/// Назначает каждому питомцу индекс цвета палитры.
///
/// Уже назначенные цвета ([stored]) сохраняются, поэтому цвет питомца не меняется,
/// когда других питомцев добавляют или удаляют и когда сервер отдаёт их в другом порядке.
/// Новым питомцам (в порядке возрастания `id`) достаётся самый редко используемый цвет,
/// при равенстве — с наименьшим индексом: пока питомцев не больше размера палитры,
/// цвета не повторяются. Питомцы, которых нет в [petIds], в результат не попадают.
Map<int, int> assignPetColors({
  required Iterable<int> petIds,
  required Map<int, int> stored,
  int paletteSize = petPaletteSize,
}) {
  final ids = petIds.toSet().toList()..sort();
  final result = <int, int>{};
  final usage = List<int>.filled(paletteSize, 0);

  for (final id in ids) {
    final index = stored[id];

    if (index != null && index >= 0 && index < paletteSize) {
      result[id] = index;
      usage[index]++;
    }
  }

  for (final id in ids) {
    if (result.containsKey(id)) {
      continue;
    }

    var best = 0;

    for (var i = 1; i < paletteSize; i++) {
      if (usage[i] < usage[best]) {
        best = i;
      }
    }

    result[id] = best;
    usage[best]++;
  }

  return result;
}
