import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tails_mobile/src/feature/pets/core/utils/pet_color_assignment.dart';

/// Хранит на устройстве цвет каждого питомца, чтобы он был одинаковым на всех экранах
/// и не менялся при изменении списка.
class PetColorStore {
  PetColorStore({required SharedPreferencesAsync preferences}) : _preferences = preferences;

  static const String _key = 'pet_colors';

  final SharedPreferencesAsync _preferences;

  /// Приводит назначения в соответствие с текущим списком питомцев: удалённые убираются,
  /// новым выдаётся цвет. Возвращает индекс цвета по `id` питомца.
  Future<Map<int, int>> sync(Iterable<int> petIds) async {
    final stored = await _read();
    final assigned = assignPetColors(petIds: petIds, stored: stored);

    if (!_equal(stored, assigned)) {
      await _write(assigned);
    }

    return assigned;
  }

  /// Цвет одного питомца; если его ещё нет, выдаёт новый, не трогая остальные.
  Future<int> colorIndexFor(int petId) async {
    final stored = await _read();
    final existing = stored[petId];

    if (existing != null && existing >= 0 && existing < petPaletteSize) {
      return existing;
    }

    final assigned = assignPetColors(petIds: [...stored.keys, petId], stored: stored);

    await _write(assigned);

    return assigned[petId]!;
  }

  Future<Map<int, int>> _read() async {
    try {
      final raw = await _preferences.getString(_key);

      if (raw == null) {
        return {};
      }

      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      return {for (final entry in decoded.entries) int.parse(entry.key): entry.value as int};
    } on Object {
      // Повреждённые данные не должны ломать экраны: цвета назначатся заново.
      return {};
    }
  }

  Future<void> _write(Map<int, int> colors) => _preferences.setString(
    _key,
    jsonEncode({for (final entry in colors.entries) '${entry.key}': entry.value}),
  );

  bool _equal(Map<int, int> a, Map<int, int> b) =>
      a.length == b.length && a.entries.every((entry) => b[entry.key] == entry.value);
}
